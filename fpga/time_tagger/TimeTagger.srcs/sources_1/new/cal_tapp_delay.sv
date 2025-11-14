`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2025 06:58:55 PM
// Design Name: 
// Module Name: cal_fine
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "settings.vh"

module cal_tapp_delay(
    input iCLK,
    input iRST,
    // communication hits_per_Tapp
    input logic [`WIDTH_HISTOGRAM-1:0] iTapp_counts,
    input logic [$clog2(`COUNTS_FOR_CAL)-1:0] iTotal_counts,
    output logic [ $clog2(`NUM_TAPPS)-1:0] oRead_Tapp_Addr,
    output logic oRead_Tapp,
    output logic oReset,
    output logic oStop_Counting,
    
    //save new Tapp Delay
    output logic [$clog2(`MAX_FINE_VAL)-1:0] oTapp_delay,
    output logic [$clog2(`NUM_TAPPS)-1:0] oTapp_num,
    output logic oWrite_new_delay,
    output logic oDelay_ready
    );
    

    //def com Delay Mem
    logic [$clog2(`NUM_TAPPS)-1:0] current_tapps;
    logic [$clog2(`NUM_TAPPS)-1:0] current_tapps_r;
    logic [$clog2(`NUM_TAPPS)-1:0] current_tapps_r2;
    logic [$clog2(`NUM_TAPPS)-1:0] current_tapps_r3;
    logic [$clog2(`NUM_TAPPS)-1:0] current_tapps_r4;
    logic [$clog2(`NUM_TAPPS)-1:0] current_tapps_r5;
    logic [$clog2(`NUM_TAPPS)-1:0] current_tapps_r6;
    //def delay cal
    logic [$clog2(`MAX_FINE_VAL)-1:0] tapp_delay;
    logic [$clog2(`MAX_FINE_VAL)-1:0] singel_tapp_delay;
    logic [$clog2(`TIME_PER_CLK*`COUNTS_FOR_CAL/10)-1:0] tmp;
    logic [$clog2(`TIME_PER_CLK*`COUNTS_FOR_CAL/10)-1:0] tmp2;
    logic  tapp_counts_zero;
    logic  tapp_counts_zero_r2;
    logic  tapp_counts_zero_r3;
    logic cal;
    logic cal_finished;
    reg intern_rst_r;
    wire reset;
    logic read_counts_w;
    logic read_counts_r;
    logic read_counts_r2;
    logic read_counts_r3;
    logic read_counts_r4;
    logic read_counts_r5;
    logic read_counts_r6;
    
    assign reset = intern_rst_r | iRST;
    assign oReset = reset;
    assign oRead_Tapp = read_counts_r ;
    assign oStop_Counting = cal;
    assign  oTapp_delay = tapp_delay;


    //checks if time for delay calculation
    always @(posedge iCLK)begin
        if (iTotal_counts >= `COUNTS_FOR_CAL)begin
            cal <= 1'b1;
        end
        else begin
            cal <= 1'b0;
        end
    end

    //sends read request for all Tapps in the channel
    always @(posedge iCLK)begin
        if (reset)begin
            current_tapps <= 0;
            read_counts_r <= 1'b0;
            cal_finished <= 1'b0;
        end
        else if (cal)begin   
            if (current_tapps <= `NUM_TAPPS-1)begin
                cal_finished <= 1'b0;
                read_counts_r <= 1'b1;
                oRead_Tapp_Addr <= current_tapps;
                current_tapps <= current_tapps + 1;
            end
            else begin
                cal_finished <= 1'b1;
                read_counts_r <=1'b0;
            end
        end 
        else begin
            read_counts_r <= 1'b0;
        end
    end
    // cal delay from the Tapp
    // TIME_PER_CLK in ps, COUNTS_FOR_CAL = Summe der Kalibrierhits
localparam int FRAC = 24; // 24..32 -> mehr Präzision = mehr Bits
// K ≈ TIME_PER_CLK_ps / COUNTS_FOR_CAL * 2^FRAC  (zur Elaboration fix berechnet)
localparam longint unsigned K =
  ((`TIME_PER_CLK << FRAC) + (`COUNTS_FOR_CAL>>1)) / `COUNTS_FOR_CAL;

localparam int W_CNT = $clog2(`COUNTS_FOR_CAL+1);

logic [W_CNT-1:0] cnt_s0;
(* use_dsp = "yes" *) logic [63:0] mul_s1;  // groß genug, damit nix überläuft
        // Zielbreite anpassen (z. B. 12..16 Bit)

always_ff @(posedge iCLK) begin
  // Stufe 0: Eingang registrieren (entkoppelt Fanout, verbessert Fmax)
  cnt_s0 <= iTapp_counts;

  // Stufe 1: konstante Fixed-Point-Mul (1 DSP48)
  mul_s1 <= cnt_s0 * K;

  // Stufe 2: rundend shiften -> Ergebnis in ps
  singel_tapp_delay <= (mul_s1 + (1<<(FRAC-1))) >> FRAC;
end
    always @(posedge iCLK)begin
        if (iTapp_counts == 0)begin
            tapp_counts_zero <= 1'b1;
        end 
        else begin        
            tapp_counts_zero <= 1'b0;
        end
    end 
    // cal delay until tapp; 
    always @(posedge iCLK)begin
        current_tapps_r <= oRead_Tapp_Addr;
        current_tapps_r2 <= current_tapps_r;
        current_tapps_r3 <= current_tapps_r2;
        current_tapps_r4 <= current_tapps_r3;
        current_tapps_r5 <= current_tapps_r4;
        current_tapps_r6 = current_tapps_r5;
        read_counts_r2 <= read_counts_r;
        read_counts_r3 <= read_counts_r2;
        read_counts_r4 <= read_counts_r3;
        read_counts_r5 <= read_counts_r4;
        read_counts_r6 <= read_counts_r5;
        tapp_counts_zero_r2 <= tapp_counts_zero;
        tapp_counts_zero_r3 <= tapp_counts_zero_r2;
        if (reset)begin
            tapp_delay <= 0;
            oWrite_new_delay <= 1'b0;
        end
        else if (read_counts_r6)begin
            if(tapp_counts_zero_r3)begin
                tapp_delay <= tapp_delay;
            end
            else begin
                tapp_delay <= tapp_delay + singel_tapp_delay;
            end
            oWrite_new_delay <= 1'b1;
            oTapp_num <= current_tapps_r6;
        end
        else begin
             oWrite_new_delay <= 1'b0;
        end
    end

    always @(posedge iCLK)begin
        if(cal_finished)begin 
            oDelay_ready <= 1'b1;
            if(read_counts_r6 == 0) begin
                intern_rst_r <= 1'b1;

            end
            else begin
                intern_rst_r <= 1'b0;
            end
        end 
        else begin
            intern_rst_r <= 1'b0;
        end
    end




endmodule
