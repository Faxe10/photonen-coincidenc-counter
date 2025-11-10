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
    logic [$clog2(`MAX_FINE_VAL)-1:0] tapp_delay;
    logic [$clog2(`MAX_FINE_VAL)-1:0] singel_tapp_delay;

    logic cal;
    logic cal_finished;
    reg intern_rst_r;
    wire reset;
    logic read_counts_w;
    logic read_counts_r;
    logic read_counts_r2;
    logic read_counts_r3;


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
        end
        else if (cal)begin   
            if (current_tapps < `NUM_TAPPS)begin
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
    always @(posedge iCLK)begin
        singel_tapp_delay <=`TIME_PER_CLK* iTapp_counts /`COUNTS_FOR_CAL;
    end
    // cal delay until tapp; 
    always @(posedge iCLK)begin
        current_tapps_r <= current_tapps;
        current_tapps_r2 <= current_tapps_r;
        current_tapps_r3 <= current_tapps_r2;
        read_counts_r2 <= read_counts_r;
        read_counts_r3 <= read_counts_r2;
        if (reset)begin
            tapp_delay <= 0;
            oWrite_new_delay <= 1'b0;
        end
        else if (read_counts_r3)begin
            tapp_delay <= tapp_delay + singel_tapp_delay;
            oWrite_new_delay <= 1'b1;
            oTapp_num <= current_tapps_r3;
        end
        else begin
             oWrite_new_delay <= 1'b0;
        end
    end

    always @(posedge iCLK)begin
        if(cal_finished)begin 
            if(read_counts_r3 == 0) begin
                intern_rst_r <= 1'b1;
                oDelay_ready <= 1'b1;
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
