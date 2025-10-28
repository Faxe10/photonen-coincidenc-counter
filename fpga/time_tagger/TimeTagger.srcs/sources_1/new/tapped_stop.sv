`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2025 08:39:51 PM
// Design Name: 
// Module Name: tapped_stop
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
module tapped_stop(

 input wire [`NUM_TAPPS-1:0] itapped_state,
 input iclk,
 input iNewTapps,
 output wire [9:0] otapped_stop_w,
 //output oEdgeDetected,
 //output oSmallEdgeDetected,
 output oNewValue
 
    );
    logic [`NUM_TAPPS-1:0] tapped_state;
    reg new_tapps_r0,new_tapps_r1,new_tapps_r2,new_tapps_r3,new_tapps_r4;
    // reg [9:0]detect_edge_part1,detect_edge_part1_r;
    //reg [9:0]detect_edge_part2,detect_edge_part2_r;
    //reg [9:0]tapped_stop_val_part1,tapped_stop_val_part1_r;
    //reg [9:0]tapped_stop_val_part2,tapped_stop_val_part2_r;
    reg [9:0]tapped_stop_val;
    reg [9:0]tapped_stop_val_part1,tapped_stop_val_part1_r;
    reg [9:0]tapped_stop_val_part2,tapped_stop_val_part2_r;
    reg [9:0]tapped_stop_val_part3,tapped_stop_val_part3_r;
    reg [9:0]tapped_stop_val_part4,tapped_stop_val_part4_r;
    reg [9:0]i;
    reg new_value;
    reg new_value_part1;
    reg new_value_part2;
    reg new_value_part3;
    reg new_value_part4;
    reg [`NUM_TAPPS-1:0] next_low,next_low_r;
    reg [`NUM_TAPPS-1:0] detect_edge,detect_edge_r;
    //reg edge_detected;
    //reg small_edge_detected; 
    //reg  [(`NUM_TAPPS-1)/2:0] detect_edge_part1, detect_edge_part2;
    //reg  [(`NUM_TAPPS-1)/2:0] next_low_part1,next_low_part2;
    reg  [(`NUM_TAPPS-1)/4:0] valid_edge_part1, valid_edge_part1_r;
    reg  [(`NUM_TAPPS-1)/4:0] valid_edge_part2, valid_edge_part2_r;
    reg  [(`NUM_TAPPS-1)/4:0] valid_edge_part3, valid_edge_part3_r;
    reg  [(`NUM_TAPPS-1)/4:0] valid_edge_part4, valid_edge_part4_r;
    assign otapped_stop_w = tapped_stop_val;
    assign oNewValue = new_value;
    //assign oEdgeDetected = edge_detected;
    //assign oSmallEdgeDetected = small_edge_detected;
    always @(posedge iclk)begin
         new_tapps_r0 <= iNewTapps;
         new_tapps_r1 <= new_tapps_r0;
         new_tapps_r2 <= new_tapps_r1;
         new_tapps_r3 <= new_tapps_r2;
         new_tapps_r4 <= new_tapps_r3;
    end 
    always @(posedge iclk) begin
        tapped_state <= itapped_state;
        if (new_tapps_r0) begin 
            for(i=0; i <=`NUM_TAPPS-4; i = i+1) begin
                detect_edge[i] <= tapped_state[i] & ~tapped_state[i+1];
                next_low[i] <= ~(tapped_state[i+2] & tapped_state[i+3]);
            end
        end
    end
    
    //always @(posedge iclk) begin
    //    if (new_tapps_r1)begin
    //       detect_edge_part1 <= detect_edge[75:0];
   //         next_low_part1 <= next_low[75:0];
    //    end
    //    if (new_tapps_r2) begin
    //        for(i=0; i <= 75; i = i+1) begin
    //            if (next_low_part1[i] && detect_edge_part1[i]) begin
    //                tapped_stop_val_part1[i] <= 1'b1;
    //            end else 
    //                tapped_stop_val_part1[i] <=1'b0;
    //        end
    //    end
    //end
    //always @(posedge iclk) begin
//        if (new_tapps_r1)begin
//            detect_edge_part2 <= detect_edge[148:76];
//            next_low_part2 <= next_low[148:76];
//        end
//        if (new_tapps_r2)begin
//            for(i=76; i <= 149; i = i+1) begin
//                if (next_low_part2[i] && detect_edge_part2[i]) begin
//                    tapped_stop_val_part2 <= i;
//                end else 
//                    tapped_stop_val_part2 <= 0;
//            end
//        end
//    end
    always @(posedge iclk)begin
        if (new_tapps_r1 )begin
            valid_edge_part1 <= detect_edge[`NUM_TAPPS/4-1:0] & next_low[(`NUM_TAPPS-1)/4:0] ;
        end
    end
    always @(posedge iclk)begin
        if (new_tapps_r1 )begin
            valid_edge_part2 <= detect_edge[`NUM_TAPPS/4*2-1:`NUM_TAPPS/4-1] & next_low[`NUM_TAPPS/4*2-1:`NUM_TAPPS/4] ;
        end
    end
    always @(posedge iclk)begin
        if (new_tapps_r1 )begin
            valid_edge_part3 <= detect_edge[`NUM_TAPPS/4*3-1:`NUM_TAPPS/4*2-1] & next_low[`NUM_TAPPS/4*3-1:`NUM_TAPPS/4*2] ;
        end
    end
    always @(posedge iclk)begin
        if (new_tapps_r1 )begin
            valid_edge_part4 <= detect_edge[`NUM_TAPPS-1:`NUM_TAPPS/4*3-1] & next_low[`NUM_TAPPS-1:`NUM_TAPPS/4*3] ;
        end
    end
   /* always @(posedge iclk)begin
        if (new_tapps_r1 & ~small_edge_detected)begin
            for(i=0; i <=`NUM_TAPPS-4; i = i+1) begin
                if(detect_edge[i])begin
                    small_edge_detected <= 1'b1;
                    break;
                end else begin
                    small_edge_detected <= 1'b0;
                end
            end
        end
    end*/
    always @(posedge iclk)begin
        if (new_tapps_r2)begin
            for (i=`NUM_TAPPS/4-1;i>=1;i=i-1)begin
                if (valid_edge_part1[i])begin
                    tapped_stop_val_part1 <= i;
                    new_value_part1 <= 1'b1;
                    break;
                end else
                    new_value_part1 <= 1'b0; 
            end
        end else begin   
            new_value_part1 <= 1'b0;       
        end   
    end 
    always @(posedge iclk)begin
        if (new_tapps_r2)begin
            for (i=`NUM_TAPPS/4-1;i>=1;i=i-1)begin
                if (valid_edge_part2[i])begin
                    tapped_stop_val_part2 <= i;
                    new_value_part2 <= 1'b1;
                    break;
                end else
                    new_value_part2 <= 1'b0; 
            end
        end else begin   
            new_value_part2 <= 1'b0;       
        end   
    end 
    always @(posedge iclk)begin
        if (new_tapps_r2)begin
            for (i=`NUM_TAPPS/4-1;i>=1;i=i-1)begin
                if (valid_edge_part3[i])begin
                    tapped_stop_val_part3 <= i;
                    new_value_part3 <= 1'b1;
                    break;
                end else
                    new_value_part3 <= 1'b0; 
            end
        end else begin   
            new_value_part3 <= 1'b0;       
        end   
    end 
    always @(posedge iclk)begin
        if (new_tapps_r2)begin
            for (i=`NUM_TAPPS/4-1;i>=1;i=i-1)begin
                if (valid_edge_part4[i])begin
                    tapped_stop_val_part4 <= i;
                    new_value_part4 <= 1'b1;
                    break;
                end else
                    new_value_part4 <= 1'b0; 
            end
        end else begin   
            new_value_part4 <= 1'b0;       
        end   
    end 
    
    always @(posedge iclk)begin
        if (new_tapps_r3)begin
             tapped_stop_val_part1_r <=  tapped_stop_val_part1;
             tapped_stop_val_part2_r <=  tapped_stop_val_part2 *2;
             tapped_stop_val_part3_r <=  tapped_stop_val_part3 *3;
             tapped_stop_val_part4_r <=  tapped_stop_val_part4 *4;
        end
        if (new_tapps_r4)begin
            if (new_value_part4) begin
                tapped_stop_val <= tapped_stop_val_part4_r;
                new_value <= 1'b1;
            end
            else if (new_value_part3)begin
                tapped_stop_val <= tapped_stop_val_part3_r;
                new_value <= 1'b1;
            end
            else if (new_value_part2)begin
                tapped_stop_val <= tapped_stop_val_part2_r;
                new_value <= 1'b1;
            end
            else if (new_value_part1) begin
                tapped_stop_val <= tapped_stop_val_part1_r;
                new_value <= 1'b1;
            end
            else 
                new_value <= 1'b0;
        end
    end
endmodule
