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
  logic [$clog2(`NUM_TAPPS)-1:0] write_tapp_add_w;
  logic delay_ready_w;
  // debug stuff
  logic [$clog2(`NUM_TAPPS)-1:0] iRead_tapp_addr;
  logic iRead_delay;
  logic  [`WIDTH_HISTOGRAM-1:0] oDebug_rd_data;
  logic [$clog2(`MAX_FINE_VAL)-1:0] oRd_delay;
  logic iStop_delay_recal;
  logic Debug_stop_delay_recal;
  // test stuff
  logic[`WIDTH_HISTOGRAM-1:0] read_counts;
  logic [32:0]counts_total_r;
  logic [128:0]x; 
  logic [32:0]y;
  logic [$clog2(`MAX_FINE_VAL)-1:0]  random;
  logic iCLK;
  logic read_tapp_w;
  logic reset_hits;
  assign iCLK = clk;
  logic stop_counting;
      // calibration
    // calibration
    hits_per_tapp hits_per_tapp_inst(
        .iCLK(iCLK),
        .iRST(reset_hits),
        // add new hit
        .iNew_hit(new_stop_val_w),
        .iTapped_value(tapp_stop_val_w),
        //read hits\
        .iStop_Counting(stop_counting),
        .iRead_Tapp(read_tapp_w),
        .iRead_Tapp_Addr(read_tapp_addr_w),
        .oRd_data(tapp_counts_w),
        .oTotal(counts_total_w),
        //debug stuff
        .iDebug_stop_delay_recal(Debug_stop_delay_recal),
        .iDebug_Read_Tapp_Addr(iRead_tapp_addr),
        .iDebug_Read_Tapp(iRead_delay),
        .oDebug_rd_data(oDebug_rd_data)
    );
    cal_tapp_delay cal_tapp_delay_inst(
        .iCLK(iCLK),
        .iRST(reset),
        // com hist per tapp
        .iTapp_counts(tapp_counts_w),
        .iTotal_counts(counts_total_w),
        .oRead_Tapp_Addr(read_tapp_addr_w),
        .oRead_Tapp(read_tapp_w),
        .oReset(reset_hits),
        // output new delay val
        .oStop_Counting(stop_counting),
        .oTapp_delay(new_tapp_delay_w),
        .oTapp_num(write_tapp_add_w),
        .oWrite_new_delay(write_new_delay_w),
        .oDelay_ready(delay_ready_w)
    );
    gen_time_tag gen_time_tag_inst(
        .iCLK(iCLK),
        .iWrite_new_delay(write_new_delay_w),
        .iTapp_delay(new_tapp_delay_w),
        .iWrite_tapp_addr(write_tapp_add_w),
        .iDelay_ready(delay_ready_w),
        
        // gen Time Tag Stuff
        .iTapp_val(tapp_stop_val_w),
        .iNew_val(new_stop_val_w),
        //.iNS(iNS),
        //.oTime_Tag(oTime_Tag),
        // debug stuff
        .iRead_tapp_addr(iRead_tapp_addr),
        .iRead_delay(iRead_delay),
        .oRd_delay(oRd_delay)
        
    );
    always @(posedge iCLK)begin
        if (stop_counting & iStop_delay_recal)begin
            Debug_stop_delay_recal <= 1'b1;
        end
        else if (~iStop_delay_recal)begin
            Debug_stop_delay_recal <= 0'b0;
        end
    end
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
        iRead_delay <= 1'b0;
        reset_task;
        iStop_delay_recal <= 1'b0;
        for (x = 0; x <= `COUNTS_FOR_CAL * 100;x++)begin
            random = $urandom_range(5,350);
            hit(random);
            @(posedge clk);
          //  $display("test");        
        end
        iStop_delay_recal <= 1'b1;
        repeat(1000) @(posedge clk);
        for (x = 0; x <= `COUNTS_FOR_CAL * 100;x++)begin
            random = $urandom_range(5,350);
            hit(random);
            @(posedge clk);
          //  $display("test");        
        end
        iRead_delay <= 1'b1;
        $display("Start read");
        for(y = 0; y<= `NUM_TAPPS;y++)begin
            iRead_tapp_addr <= y;
            repeat (10) @(posedge clk);
            $display("Tapp: %0d |Counts: %0d |Delay: %0d",y,oDebug_rd_data,oRd_delay);
        end
        @(posedge clk);
        $finish;
    end
endmodule
