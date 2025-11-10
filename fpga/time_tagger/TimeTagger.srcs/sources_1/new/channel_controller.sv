`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Light and Matter Group, Leibniz University Hannover
// Engineer: Fabian Walther fabian@cryptix.de
//
// Create Date: 11/7/2025 01:12:19 PM
// Design Name: Photonen Coincidence Counter
// Module Name: channel_controller
// Project Name: 2QA Entanglement demonstrator
// Target Devices: EBAZ4205
// Tool Versions:
// Description:
// This controlles one Tapp Delay line Channel from the Tapp Delay line
//  to Time Tag
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`include "settings.vh"

module channel_controller(
    input logic iCLK,
    input logic iCH,
    input logic iRST,
    output logic [`WIDTH_TIME_TAG:0]oTime_Tag
    );
    logic reset;
    //wires for Tapp Delay Line
    wire new_hit_w;
    wire  [`NUM_TAPPS-1:0] tapped_state_w;
    //wires for Tapped_stop
    wire new_stop_va;
    wire [$clog2(`NUM_TAPPS):0] tapp_stop_val_w;
    // wires for hits per Tapp
    wire [$clog2(`COUNTS_FOR_CAL)-1:0] counts_total_w;
    wire [`WIDTH_HISTOGRAM-1:0] tapp_counts_w;
    wire read_counts_ready_w;
    wire [ $clog2(`NUM_TAPPS)-1:0] read_tapp_addr_w;
    wire read_tapp_w;
    // wires for  cal tapp delay
    wire write_new_delay_w;
    wire logic [$clog2(`MAX_FINE_VAL)-1:0] new_tapp_delay_w;
    wire logic [$clog2(`NUM_TAPPS)-1:0] write_tapp_add_w;
    assign reset = iRST;
    tapped_delay_line inst_tapped_delay_line(
        .iCLK(iCLK),
        .iCH(iCH),
        .oNew_hit(new_hit_w),
        .oTAPPED_STATE(tapped_state_w)
    );
    tapped_stop tapped_stop_inst (
        .iCLK(iCLK),
        .iNewTapps(new_hit_w),
        .itapped_state(tapped_state_w),
        .otapped_stop_w(tapp_stop_val_w),
        .oNewValue(new_stop_val_w)
    );

    // calibration
    hits_per_tapp hits_per_tapp_inst(
        .iCLK(iCLK),
        .iRST(reset),
        // add new hit
        .iNew_hit(new_stop_val_w),
        .iTapped_value(tapp_stop_val_w),
        //read hits\
        .iStop_Counting(),
        .iRead_Tapp(read_tapp_w),
        .iRead_Tapp_Addr(read_tapp_addr_w),
        .oRd_data(tapp_counts_w),
        .oTotal(counts_total_w)
    );
    cal_tapp_delay cal_tapp_delay_inst(
        .iCLK(iCLK),
        .iRST(reset),
        // com hist per tapp
        .iTapp_counts(tapp_counts_w),
        .iTotal_counts(counts_total_w),
        .oRead_Tapp_Addr(read_tapp_addr_w),
        .oRead_Tapp(read_tapp_W),
        // output new delay val
        .oTapp_delay(new_tapp_delay_w),
        .oTapp_num( write_tapp_add_w),
        .oWrite_new_delay(write_new_delay_w)
    );
    gen_time_tag gen_time_tag_inst(
        .iCLK(iCLK),
        .iWrite_new_delay(write_new_delay_w),
        .iTapp_delay(new_tapp_delay_w),
        .iWrite_tapp_addr(write_tapp_add_w)
    );


    // create time Tagg

endmodule