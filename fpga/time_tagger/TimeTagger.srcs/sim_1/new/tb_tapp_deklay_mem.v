`timescale 1ns/1ps
`default_nettype none

// --- Falls keine settings.vh vorhanden ist, hier Defaults setzen ---
`ifndef SETTINGS_VH
  `define SETTINGS_VH
  `define NUM_TAPPS     16
  `define Channel_num   4
  `define MAX_FINE_VAL  64
`endif

module tb_tapped_delay_mem;

  // -------------------- Lokale Parameter/Typen --------------------
  localparam int CH     = `Channel_num;
  localparam int TAPPW  = $clog2(`NUM_TAPPS);
  localparam int FINEW  = $clog2(`MAX_FINE_VAL);

  // Design-Latenzen (aus deinem Code abgeleitet)
  localparam int WRITE_TO_RAM_LAT   = 1;  // iWrite -> RAM-Write wirksam
  localparam int READ_TO_OUT_LAT    = 2;  // iRead  -> oTapp_Delay gültig

  // -------------------- Testbench-Signale -------------------------
  logic clk;

  logic [CH-1:0]                        iRead;
  logic [CH*TAPPW-1:0]                  iRead_Tapp;
  logic [CH*FINEW-1:0]                  oTapp_Delay;

  logic [CH-1:0]                        iWrite;
  logic [CH*TAPPW-1:0]                  iWrite_Tapp;
  logic [FINEW-1:0]                     iDelay_write_val;

  // -------------------- DUT-Instanz -------------------------------
  tapped_delay_mem dut (
    .iCLK           (clk),
    .iRead          (iRead),
    .iRead_Tapp     (iRead_Tapp),
    .oTapp_Delay    (oTapp_Delay),

    .iWrite         (iWrite),
    .iWrite_Tapp    (iWrite_Tapp),
    .iDelay_write_val(iDelay_write_val)
  );

  // -------------------- Clock-Gen --------------------------------
  initial clk = 0;
  always #5 clk = ~clk; // 100 MHz

  // -------------------- Scoreboard -------------------------------
  // Erwartete RAM-Werte je Channel/Tapp
  int unsigned exp_mem   [CH][`NUM_TAPPS];
  bit          wrote_flag[CH][`NUM_TAPPS];

  // -------------------- Hilfsfunktionen --------------------------
  // packe pro-Channel-Tapp-Indizes in flachen Bus
  function automatic logic [CH*TAPPW-1:0] pack_tapp(input int unsigned tapp_idx [CH]);
    logic [CH*TAPPW-1:0] bus;
    for (int ch_i = 0; ch_i < CH; ch_i++)
      bus[ch_i*TAPPW +: TAPPW] = logic'(tapp_idx[ch_i][TAPPW-1:0]);
    return bus;
  endfunction

  // lese Delay-Feld eines Channels aus flachem Output-Bus
  function automatic int unsigned get_delay_ch(input logic [CH*FINEW-1:0] bus, input int ch_sel);
    return int'(bus[ch_sel*FINEW +: FINEW]);
  endfunction

  // Setzt alle Eingänge auf definierte Ruhewerte
  task automatic clear_inputs();
    iRead            = '0;
    iRead_Tapp       = '0;
    iWrite           = '0;
    iWrite_Tapp      = '0;
    iDelay_write_val = '0;
  endtask

  // Eine Write-Operation: schreibt (val) an (ch,tapp)
  task automatic write_one(input int unsigned ch, input int unsigned tapp, input int unsigned val);
    int unsigned wt[CH];
    // alle Tapp-Indizes nullen, nur ausgewählten Channel setzen
    for (int i=0;i<CH;i++) wt[i] = 0;
    wt[ch] = tapp;

    iWrite_Tapp      = pack_tapp(wt);
    iDelay_write_val = val[FINEW-1:0];
    iWrite           = '0;
    iWrite[ch]       = 1'b1;

    @(posedge clk); // write_r wird im DUT registriert

    iWrite           = '0;

    // warten bis Write im RAM wirksam ist
    repeat (WRITE_TO_RAM_LAT) @(posedge clk);

    // Scoreboard aktualisieren
    exp_mem[ch][tapp]    = val & ((1<<FINEW)-1);
    wrote_flag[ch][tapp] = 1'b1;
  endtask

  // Eine Read-Operation + Check: liest (ch,tapp) und vergleicht gegen Scoreboard
  task automatic read_check(input int unsigned ch, input int unsigned tapp, input string tag="");
    int unsigned rd[CH];
    for (int i=0;i<CH;i++) rd[i] = 0;
    rd[ch] = tapp;

    iRead_Tapp  = pack_tapp(rd);
    iRead       = '0;
    iRead[ch]   = 1'b1;

    @(posedge clk); // read_r im DUT registriert
    iRead       = '0;

    // warten bis oTapp_Delay gültig ist
    repeat (READ_TO_OUT_LAT) @(posedge clk);

    int unsigned got = get_delay_ch(oTapp_Delay, ch);
    int unsigned exp = exp_mem[ch][tapp] & ((1<<FINEW)-1);

    if (!wrote_flag[ch][tapp]) begin
      $display("[%0t] WARN (%s) ch=%0d tapp=%0d wurde nie geschrieben; Output=%0d",
               $time, tag, ch, tapp, got);
    end else if (got !== exp) begin
      $error("[%0t] FAIL (%s) ch=%0d tapp=%0d  exp=%0d  got=%0d",
             $time, tag, ch, tapp, exp, got);
      $fatal(1);
    end else begin
      $display("[%0t] PASS (%s) ch=%0d tapp=%0d  val=%0d",
               $time, tag, ch, tapp, got);
    end
  endtask

  // -------------------- Testablauf -------------------------------
  initial begin
    // Init
    clear_inputs();
    for (int c=0;c<CH;c++) for (int t=0;t<`NUM_TAPPS;t++) begin
      exp_mem[c][t]    = '0;
      wrote_flag[c][t] = 1'b0;
    end

    // paar Takte Leerlauf
    repeat (3) @(posedge clk);

    // ---- gerichtete Writes ----
    // Schreibe einige bekannte Werte pro Channel/Adresse
    for (int c=0;c<CH;c++) begin
      write_one(c, 0,  (c<<4) + 1);
      write_one(c, 1,  (c<<4) + 2);
      write_one(c, 2,  (c<<4) + 3);
      write_one(c, 7,  (c<<4) + 9);
      write_one(c, `NUM_TAPPS-1, (c<<4) + 15);
    end

    // ---- gerichtete Reads ----
    for (int c=0;c<CH;c++) begin
      read_check(c, 0,            "dir");
      read_check(c, 1,            "dir");
      read_check(c, 2,            "dir");
      read_check(c, 7,            "dir");
      read_check(c, `NUM_TAPPS-1, "dir");
    end

    // ---- zufällige Writes + Reads ----
    int unsigned seed = 32'hC0FFEE01;
    for (int k=0; k<200; k++) begin
      int unsigned ch   = $urandom(seed) % CH;
      int unsigned tapp = $urandom(seed) % `NUM_TAPPS;
      int unsigned val  = $urandom(seed) % `MAX_FINE_VAL;

      write_one(ch, tapp, val);

      // gelegentlich gleichzeitig mehrere Reads (versch. Channels/Adressen)
      if ((k % 7) == 0) begin
        // baue ein Read-Burst über alle Channels
        int unsigned rd_idx[CH];
        for (int c=0;c<CH;c++) begin
          // suche eine bereits geschriebene Adresse für jeden Channel
          int unsigned pick = 0;
          bit found = 0;
          for (int t=0; t<`NUM_TAPPS; t++) if (wrote_flag[c][t]) begin pick=t; found=1; break; end
          rd_idx[c] = found ? pick : 0;
        end
        // drive Read-Burst
        iRead_Tapp = pack_tapp(rd_idx);
        iRead      = '1;          // alle Channels lesen
        @(posedge clk);
        iRead      = '0;
        repeat (READ_TO_OUT_LAT) @(posedge clk);
        // verifizieren
        for (int c=0;c<CH;c++) begin
          if (wrote_flag[c][rd_idx[c]]) begin
            int unsigned got = get_delay_ch(oTapp_Delay, c);
            int unsigned exp = exp_mem[c][rd_idx[c]] & ((1<<FINEW)-1);
            if (got !== exp) begin
              $error("[%0t] FAIL (burst) ch=%0d tapp=%0d exp=%0d got=%0d",
                     $time, c, rd_idx[c], exp, got);
              $fatal(1);
            end else begin
              $display("[%0t] PASS (burst) ch=%0d tapp=%0d val=%0d",
                       $time, c, rd_idx[c], got);
            end
          end
        end
      end else begin
        // Einzel-Read auf den letzten geschriebenen Eintrag
        read_check(ch, tapp, "rand");
      end
    end

    $display("=== ALLE TESTS PASSIERT ===");
    $finish;
  end

endmodule
