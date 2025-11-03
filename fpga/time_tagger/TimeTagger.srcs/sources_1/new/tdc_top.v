`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2025 08:38:05 PM
// Design Name: 
// Module Name: tdc_top
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

module tdc_top(
    input clk,
    input channel1,
    input irst,
    input wire [$clog2(`NUM_TAPPS-1):0]counts_addr,
    output reg [31:0] tapped_1,
    output reg [31:0] tapped_end,
    output reg [9:0] oTapped_value,
    output reg [`WIDHT_HISTOGRAM-1:0]oCounts_tapps,
    output reg EdgeDetected,
    output wire [31:0]total,
    output wire new_tapp,
    output wire oSmallEdgeDetected,
    output reg [$clog2(`NUM_TAPPS-1):0] oCounts_addr,
    output reg new_stop_value_r
    
//output reg [31:0]tapped_1,
//output reg[31:0]tapped_3,
//output reg [31:0]tapped_4,
//output reg [31:0]tapped_5,
//output reg[31:0]tapped_6,
//output reg [31:0]tapped_7,
//output reg [31:0]tapped_8,
//output reg[31:0]tapped_9,
//output reg [31:0]tapped_10,
//output reg [31:0]tapped_11,
//output reg[31:0]tapped_12,
//output reg [31:0]tapped_13,
//output reg [31:0]tapped_14,
//output reg[31:0]tapped_15,
//output reg[31:0]tapped_16
    );
    wire  [`NUM_TAPPS-1:0] tapped_state_w; 
    wire [9:0]tapped_stop_w;
    wire [`WIDHT_HISTOGRAM-1:0] counts_tapp_w;
    wire new_hit_w;
    wire edgedetected_w;
    reg new_hit_r;
    reg new_hit_r2;
    reg new_hit_r3;
    wire new_stop_value_w;
    always @(posedge clk) oTapped_value <= tapped_stop_w;
    always @(posedge clk) tapped_1 <= tapped_state_w[31:0];
    always @(posedge clk) tapped_end <= tapped_state_w[449:418];
    always @(posedge clk) oCounts_tapps <= counts_tapp_w;
    always @(posedge clk) new_hit_r <= new_hit_w;
    always @(posedge clk) new_hit_r2 <= new_hit_r;
    always @(posedge clk) new_hit_r3 <= new_hit_r2;
    always @(posedge clk) new_stop_value_r <= new_stop_value_w; 
    always @(posedge clk) EdgeDetected <= edgedetected_w;
    always @(posedge clk) oCounts_addr <= counts_addr;
    assign new_tapp = new_hit_w;
    tapped_delay_line inst_tapped_delay_line(
        .iCLK(clk),
        .iChannel(channel1),
        .oNew_hit(new_hit_w),
        .oTAPPED_STATE(tapped_state_w)
    );
    tapped_stop tapped_stop_inst (
        .iclk(clk),
        .iNewTapps(new_hit_w),
        .itapped_state(tapped_state_w),
        .otapped_stop_w(tapped_stop_w),
        .oNewValue(new_stop_value_w)
        //.oEdgeDetected(edgedetected_w),
        //.oSmallEdgeDetected(oSmallEdgeDetected)
    );
    histogramm histogramm_inst(
        .iCLK(clk),
        .iTapped_value(tapped_stop_w),
        .iNew_hit(new_stop_value_w),
        .iRst(irst),
        .iRd_addr(counts_addr),
        .oRd_data(counts_tapp_w),
        .oTotal(total)
        );
    //test inst_test(
    //    .hi(1'b1)
     //   );
        
endmodule
