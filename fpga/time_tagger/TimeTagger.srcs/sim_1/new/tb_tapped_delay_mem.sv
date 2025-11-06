`timescale 1ns/1ps
`default_nettype none

// --- Defaults, falls keine settings.vh eingebunden ist ---
`ifndef SETTINGS_VH
  `define SETTINGS_VH
  `define NUM_TAPPS     400
  `define Channel_num   8
  `define MAX_FINE_VAL  4000
`endif

module tb_tapped_delay_mem_simple;

  // abgeleitete Breiten
  localparam int CH    = `Channel_num;
  localparam int TAPPW = $clog2(`NUM_TAPPS);
  localparam int FINEW = $clog2(`MAX_FINE_VAL);
  logic [$clog2(CH):0]ch_count;
  logic [TAPPW-1:0]tapp_count;
  logic [$clog2(`MAX_FINE_VAL)-1:0]value[`NUM_TAPPS:0][`Channel_num];
  // Takt
  logic clk = 0;
  always #5 clk = ~clk; // 100 MHz

  // DUT-Ports
  logic                       iCLK;
  logic [CH-1:0]              iRead;
  logic [CH*TAPPW:0]        iRead_Tapp;
  logic [CH*FINEW:0]        oTapp_Delay;

  logic [CH:0]              iWrite;
  logic [CH*TAPPW:0]        iWrite_Tapp;
  logic [FINEW-1:0]           iDelay_write_val;
  // DUT
  tapped_delay_mem dut (
    .iCLK            (clk),
    .iRead           (iRead),
    .iRead_Tapp      (iRead_Tapp),
    .oTapp_Delay     (oTapp_Delay),
    .iWrite          (iWrite),
    .iWrite_Tapp     (iWrite_Tapp),
    .iDelay_write_val(iDelay_write_val)
  );

  // einfache Warte-Tasks
  task automatic wait_clks(input int n);
    repeat (n) @(posedge clk);
  endtask


  // Stimulus
  initial begin
    $display("start");
    iWrite = 8'b00000001;
    iWrite_Tapp = 1;
    iDelay_write_val = 50;
    wait_clks(5);
    iWrite = 8'b00000000;
    iRead = 8'b00000001;
    iRead_Tapp = 1;
    for (ch_count = 0; ch_count < `Channel_num;ch_count++)begin
        $display("Write channel ", ch_count);
        for (tapp_count = 0; tapp_count <= `NUM_TAPPS;tapp_count++)begin
            iWrite = 8'b00000000;
            iRead = 8'b00000000;
            iWrite[ch_count] = 1'b1;
            iRead[ch_count] = 1'b1;
            value[tapp_count][ch_count] = $urandom_range(`MAX_FINE_VAL,0);
            iDelay_write_val = value[tapp_count][ch_count];
            if (ch_count ==0)begin
                iWrite_Tapp = tapp_count;
            end 
            else if (ch_count == 1)begin
                iWrite_Tapp[2*TAPPW-1:TAPPW] = tapp_count;
            end
            else if (ch_count == 2)begin
                iWrite_Tapp[3*TAPPW-1:TAPPW*2] = tapp_count;
            end 
            else if (ch_count == 3)begin
                iWrite_Tapp[4*TAPPW-1:TAPPW*3] = tapp_count;
            end
            else if( ch_count == 4)begin
                iWrite_Tapp[5*TAPPW-1:TAPPW*4] = tapp_count;
            end
            else if( ch_count == 5)begin                       
                iWrite_Tapp[6*TAPPW-1:TAPPW*5] = tapp_count;  
            end 
            else if( ch_count == 6)begin                       
                iWrite_Tapp[7*TAPPW-1:TAPPW*6] = tapp_count;  
            end 
            else if( ch_count == 7)begin                       
                iWrite_Tapp[8*TAPPW-1:TAPPW*7] = tapp_count;  
            end 
            wait_clks(1);                                             
            
        end
    end
    $display("finished write");
    for (ch_count = 0; ch_count < `Channel_num;ch_count++)begin
        $display("read channel ", ch_count);
        for (tapp_count = 0; tapp_count <= `NUM_TAPPS;tapp_count++)begin
            if (ch_count ==0)begin
                iRead_Tapp = tapp_count;
            end 
            else if (ch_count == 1)begin
                iRead_Tapp[2*TAPPW-1:TAPPW] = tapp_count;
            end
            else if (ch_count == 2)begin
                iRead_Tapp[3*TAPPW-1:TAPPW*2] = tapp_count;
            end 
            else if (ch_count == 3)begin
                iRead_Tapp[4*TAPPW-1:TAPPW*3] = tapp_count;
            end
            else if( ch_count == 4)begin
                iRead_Tapp[5*TAPPW-1:TAPPW*4] = tapp_count;
            end
            else if( ch_count == 5)begin                       
                iRead_Tapp[6*TAPPW-1:TAPPW*5] = tapp_count;  
            end 
            else if( ch_count == 6)begin                       
                iRead_Tapp[7*TAPPW-1:TAPPW*6] = tapp_count;  
            end 
            else if( ch_count == 7)begin                       
                iRead_Tapp[8*TAPPW-1:TAPPW*7] = tapp_count;  
            end 
            wait_clks(4);
            if (value[tapp_count][ch_count] == oTapp_Delay)begin
                $display("error false Value saved");
            end
        end
    end
    $display("finished");
    $finish;
  end

endmodule
