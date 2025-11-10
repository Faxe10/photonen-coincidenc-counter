`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Light and Matter Group, Leibniz University Hannover
// Engineer: Fabian Walther fabian@cryptix.de
// 
// Create Date: 11/10/2025 03:07:19 PM
// Design Name: Photonen Coincidence Counter
// Module Name: tb_hits_per_tapp
// Project Name: 2QA Entanglement demonstrator
// Target Devices: EBAZ4205
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
`default_nettype none
`include "settings.vh"
module tb_hits_per_tapp(

    );

  //clock stuff
  logic clk;
  initial clk = 0;
  always #5 clk = ~clk; // 100 MHz
  // port stuff
  logic reset;
  logic new_stop_val_w;
  logic [$clog2(`NUM_TAPPS)-1:0]tapp_stop_val_w;
  logic stop_counting_w;
  logic read_tapp_w;
  logic [$clog2(`NUM_TAPPS)-1:0] read_tapp_addr_w;
  logic  [`WIDTH_HISTOGRAM-1:0]tapp_counts_w;
  logic [32:0]counts_total_w;
  
  
  // test stuff
  logic[`WIDTH_HISTOGRAM-1:0] read_counts;
  logic [32:0]counts_total_r;
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
    task automatic  read(input int addr);
        begin
            read_tapp_addr_w <= addr;
            read_tapp_w <= 1'b1;
            @(posedge clk);
            read_tapp_w <= 1'b0;
            @(posedge clk);
            read_counts <= tapp_counts_w;
            @(posedge clk);
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
        stop_counting_w <= 1'b0;
        reset_task;
        repeat (400)@(posedge clk);
        hit(5);
        read(5);
        if (read_counts != 1)begin 
              $display("error counts false");
        end
        hit(100);
        hit(100);
        hit(100);
        read(100);
        if (read_counts != 3)begin 
              $display("error counts false");
        end   
        hit(101);
        if (read_counts != 3)begin 
              $display("error counts false");
        end  
        hit(100);
        hit(101);
        hit(100);
        read(100);
        if (read_counts != 5)begin 
              $display("error counts false");
        end  
        counts_total_r <= counts_total_w;
        reset_task;
        repeat(400) @(posedge clk); 
        read(100);
        if (read_counts != 0)begin 
              $display("error reset dosent work");
        end  
    end
endmodule
