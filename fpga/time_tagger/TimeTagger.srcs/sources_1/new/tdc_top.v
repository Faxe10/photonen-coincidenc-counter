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
    input wire read_counts,
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
    
    //debug ports
    /*input wire         iRead_w[`Channel_num-1:0],
    input wire  [$clog2(`NUM_TAPPS)-1:0]    iRead_Tapp_w,
    input wire  [$clog2(`Channel_num)-1:0]  iRead_Channel_w,
    output wire [$clog2(`MAX_FINE_VAL)-1:0] oTapp_Delay_w,
    
    input wire [$clog2(`Channel_num)-1:0]   iWrite_channel_w,
    input wire [$clog2(`NUM_TAPPS)-1:0]     iWrite_Tapp_w,
    input wire [$clog2(`MAX_FINE_VAL)-1:0]  iDelay_write_val_w,
    input wire iWrite_w*/
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
    wire [`Channel_num-1:0]iRead_w;
    wire  [`Channel_num*$clog2(`NUM_TAPPS)-1:0]iRead_Tapp_w;
    wire  [$clog2(`Channel_num)-1:0]  iRead_Channel_w;
    wire [$clog2(`MAX_FINE_VAL)-1:0] oTapp_Delay_w;
    wire [$clog2(`Channel_num)-1:0]   iWrite_channel_w;
    wire [`Channel_num*$clog2(`NUM_TAPPS)-1:0]     iWrite_Tapp_w;
    wire [$clog2(`MAX_FINE_VAL)-1:0]  iDelay_write_val_w;
    wire iWrite_w;
    wire  [`NUM_TAPPS-1:0] tapped_state_w; 
    wire [9:0]tapped_stop_w;
    wire [`WIDHT_HISTOGRAM-1:0] counts_tapp_w;
    wire new_hit_w;
    wire edgedetected_w;
    reg new_hit_r;
    reg new_hit_r2;
    reg new_hit_r3;
    wire new_stop_value_w;
    wire Rd_data_ready;
    wire [$clog2(`MAX_FINE_VAL)-1:0] oTapp_Delay_w2 [`Channel_num:0];
    wire [$clog2(`NUM_TAPPS)-1:0] iRead_Tapp_w2 [`Channel_num:0];

    always @(posedge clk) oTapped_value <= tapped_stop_w;
    always @(posedge clk) tapped_1 <= tapped_state_w[31:0];
    always @(posedge clk) tapped_end <= tapped_state_w[399:368];
    //always @(posedge clk) oCounts_tapps <= counts_tapp_w;
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
    cal_tapp_delay cal_tapp_delay_inst(
        .iCLK(clk),
        .iRST(irst),
        .iNew_stop_value()

    tapped_delay_mem tapped_delay_mem_inst(
        .iCLK(c),
        .iRead(iRead_w), 
        .iRead_Tapp(iRead_Tapp_w),
        .oTapp_Delay(oTapp_Delay_w),
        .iWrite_Tapp(iWrite_Tapp_w),
        .iDelay_write_val(iDelay_write_val_w),
        .iWrite(iWrite_w)
        );
    //test inst_test(
    //    .hi(1'b1)
     //   );
    always @(posedge clk)begin  
            oCounts_tapps <= counts_tapp_w; 
    end
endmodule
