`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2025 11:02:00 PM
// Design Name: 
// Module Name: historgamm
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
module histogramm(
    input logic iCLK,
    input logic iNew_hit,
    input logic iRst,
    input logic [ $clog2(`NUM_TAPPS-1):0]iTapped_value,
    input logic [ $clog2(`NUM_TAPPS-1):0]iRd_addr,
    output logic [`WIDHT_HISTOGRAM:0] oRd_data,
    output logic [32:0] oTotal
    );
    logic [`WIDHT_HISTOGRAM-1:0] cnt [0:`NUM_TAPPS-1];
    reg [32:0]total;
    reg [ $clog2(`NUM_TAPPS-1):0]tapped_delay_value_r;
    reg new_hit_r;
    logic [ $clog2(`NUM_TAPPS-1):0] iRd_addr_r;
    always @(posedge iCLK) iRd_addr_r <= iRd_addr;
    always @(posedge iCLK) oTotal <= total;
    always @(posedge iCLK) oRd_data <= cnt[iRd_addr_r];
    always @(posedge iCLK)begin
        tapped_delay_value_r <= iTapped_value;
        new_hit_r <= iNew_hit;
        if (iRst) begin
            for (int i = 0; i<`WIDHT_HISTOGRAM-1;i++)
                cnt[i]<= `WIDHT_HISTOGRAM'd0;
            total <= 32'd0 ;
        end
        else if (new_hit_r)begin 
            cnt[tapped_delay_value_r] <= cnt[tapped_delay_value_r] + 1;
            total <= total +1;
        end
    end
endmodule
