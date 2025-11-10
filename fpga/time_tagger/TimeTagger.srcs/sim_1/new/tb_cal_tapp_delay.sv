`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2025 05:56:47 PM
// Design Name: 
// Module Name: tb_cal_tapp_delay
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
//////////////////////////////////////////////////////////////////////////////////
`default_nettype none
`include "settings.vh"

module tb_cal_tapp_delay(

    );
    
  //clock stuff
  logic clk;
  initial clk = 0;
  always #5 clk = ~clk; // 100 MHz
  // port  hits_per_tapp stuff
  logic reset;
  logic new_stop_val_w;
  logic [$clog2(`NUM_TAPPS)-1:0]tapp_stop_val_w;
  logic stop_counting_w;
  logic read_tapp_w;
  logic [$clog2(`NUM_TAPPS)-1:0] read_tapp_addr_w;
  logic  [`WIDTH_HISTOGRAM-1:0]tapp_counts_w;
  logic [32:0]counts_total_w;
  //port cal tapp delay stuff
  logic write_new_delay_w;
  logic [$clog2(`MAX_FINE_VAL)-1:0]  new_tapp_delay_w;
  logic [$clog2(`NUM_TAPPS)-1:0] write_tapp_addr_w;
  
  // test stuff
  logic[`WIDTH_HISTOGRAM-1:0] read_counts;
  logic [32:0]counts_total_r;
  logic [32:0]x; 
  logic [$clog2(`MAX_FINE_VAL)-1:0]  random;
  hits_per_tapp hits_per_tapp_inst(
        .iCLK(clk),
        .iRST(reset),
        // add new hit
        .iNew_hit(new_stop_val_w),
        .iTapped_value(tapp_stop_val_w),
        //read hits\
        .iStop_Counting(stop_counting_w),
        .iRead_Tapp(read_tapp_w),
        .iRead_Tapp_Addr(read_tapp_addr_w),
        .oRd_data(tapp_counts_w),
        .oTotal(counts_total_w)
    );
     cal_tapp_delay cal_tapp_delay_inst(
        .iCLK(clk),
        .iRST(reset),
        // com hist per tapp
        .iTapp_counts(tapp_counts_w),
        .iTotal_counts(counts_total_w),
        .oRead_Tapp_Addr(read_tapp_addr_w),
        .oRead_Tapp(read_tapp_w),
        .oStop_Counting(stop_counting_w),
        // output new delay val
        .oTapp_delay(new_tapp_delay_w),
        .oTapp_num( write_tapp_addr_w),
        .oWrite_new_delay(write_new_delay_w)
    );
    gen_time_tag gen_time_tag_inst(
        .iCLK(clk),
        .iWrite_new_delay(write_new_delay_w),
        .iTapp_delay(new_tapp_delay_w),
        .iWrite_tapp_addr(write_tapp_addr_w)
    );
    task automatic hit( input int addr);
        begin
            @(posedge clk);
            tapp_stop_val_w <= addr;
            new_stop_val_w <= 1'b1;
            @(posedge clk);
            new_stop_val_w <= 1'b0;
            repeat (4) @(posedge clk);
        end
    endtask

    task automatic reset_task ();
        begin 
            reset <= 1'b1;
            @(posedge clk);
            reset <= 1'b0;
        end
    endtask
    initial begin
        reset_task;
        for (x = 0; x <= `COUNTS_FOR_CAL+1;x++)begin
            random = $urandom_range(400);
            hit(random);
            @(posedge clk);
            $display("test");        
        end
    end
endmodule
