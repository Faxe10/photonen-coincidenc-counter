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
    input logic [`WIDHT_HISTOGRAM-1:0] iTapp_counts,
    input logic [clog2('COUNTS_FOR_CAL)-1:0] iTotal_counts,
    input logic iRead_counts_ready,
    output logic [ $clog2(`NUM_TAPPS-):0] oRead_Tapp_Addr,
    output logic oRead_Tapp,
    //save new Tapp Delay
    output logic [$clog2(`MAX_FINE_VAL)-1:0] oTapp_delay,
    output logic [$clog2(`NUM_TAPPS)-1:0] oTapp_num,
    output logic oWrite_new_delay,
    );
    logic cal,cal_old;
    logic [`Channel_num:0]write_ch;
    logic [$clog2(`Channel_num):0] current_cal_ch;
    logic [$clog2(`NUM_TAPPS:0] current_tapps_request;
    logic [$clog2(`NUM_TAPPS:0] current_tapps_response;
    logic [$clog2(`NUM_TAPPS:0] current_tapps_response_r;
    logic [$clog2(`NUM_TAPPS:0] current_tapps_response_r2;
    logic [ $clog2(`NUM_TAPPS-1):0] read_counts_addr_w;
    logic [ $clog2(`NUM_TAPPS-1):0] read_counts_addr_r;
    logic [ `WIDHT_HISTOGRAM:0] read_tapp_val;
    logic [$clog2(`MAX_FINE_VAL:0] fine_val;
    logic [$clog2(`MAX_FINE_VAL:0] fine_val_r;
    logic [`MAX_FINE_VAL:0] delay_to_tapp;
    logic [`MAX_FINE_VAL:0] tapp_delay;
    logic new_fine_val;
    logic new_tapp_delay;
    reg intern_rst_r;
    wire reset;
    logic read_counts_w;
    logic read_counts_r;
    assign read_counts_addr_w = read_counts_addr_r;
    assign read_counts_w <= read_counts_r;
    assign reset = intern_rst_r | iRST;
    assign oWrite_ch = write_ch;
    assign oWrite_Tapp = current_tapps_response_r2;
    assign oDelay_Tapp = delay_to_tapp;




    always @(posedge iCLK)begin
        current_tapps_response_r <= current_tapps_response;
        current_tapps_response_r2 <= current_tapps_response_r;
        fine_val_r <= fine_val;
    end
    //checks if time for delay calculation
    always @(posedge iCLK)begin
        if (total >= `Counts_for_cal)begin
            cal <= 1'b1;
        end
        else begin
            cal <= 1'b0;
        end
    end

    //sends read request for all Tapps in the channel
    always @(posedge iCLK)begin
        if (reset)begin
            current_tapps_request <= 0;
            read_counts_r <= 1'b0;
        end
        else if (cal)begin
            if (current_tapps <= `NUM_TAPPS)begin
                read_counts_addr_r <= current_tapps;
                read_counts_r <= 1'b1;
                current_tapps <= current_tapps + 1;
            end
        end
    end
    // cal of the delay vals
    always @(posedge iCLK)begin
        if (reset)begin
            intern_rst_r <= 1'b0;
            current_tapps_response <= 1'b0;
            new_tapp_delay <= 1'b0;
        end
        else begin
            if(current_tapps_response == `NUM_TAPPS)begin
                intern_rst_r <= 1'b1;
            end
            if (cal)begin
                if (Rd_data_ready)begin
                    tapp_delay <= read_tapp_val * `TIME_PER_CLK/`Counts_for_cal;
                    current_tapps_response <= current_tapps_response + 1;
                    new_tapp_delay <= 1'b1;
                end
                else begin
                    new_tapp_delay <= 1'b0;
                end
            end
            else begin
                new_tapp_delay <= 1'b0;
            end
        end
    end
    always @(posedge iCLK)begin
        if (reset) begin
            delay_to_tapp <= 0;
        end
        else if (new_tapp_delay) begin
            delay_to_tapp <= delay_to_tapp + tapp_delay;
        end
    end



endmodule
