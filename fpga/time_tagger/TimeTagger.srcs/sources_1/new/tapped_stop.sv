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
    //reg [9:0]i;
    reg new_value;
    logic [10:0]index_max_edge[7:0];
    logic [9:0] val_max_edge[7:0];
    logic [9:0] val_max_edge_2[1:0];
    logic [9:0] found;
    reg [9:0] i;
    reg [`NUM_TAPPS-1:0] next_low,next_low_r;
    reg [`NUM_TAPPS-1:0] detect_edge,detect_edge_r;
    reg[`NUM_TAPPS-1:0] valid_edge_w; 
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
    genvar x;
    generate 
        for (x=0; x<`NUM_TAPPS-3;x++)begin 
            always @(posedge iclk) begin
                if (new_tapps_r0)begin
                    valid_edge_w[x] <= tapped_state[x] & ~tapped_state[x+1] & ~tapped_state[x+2] &  ~tapped_state[x+3];
                end
            end
        end
    endgenerate
    function [10:0] msb_index;   
        input [(`NUM_TAPPS-3)/8:0] ivalid_edge;
        begin
            automatic int return_value = 0;
            automatic int z;
            for (z=(`NUM_TAPPS-3)/8;z>=0;z--) begin
                if (ivalid_edge[z]) begin 
                    return_value[9:0] = z[9:0];
                    return_value[10] = 1'b1;
                    break;
                end else
                     return_value = 0;
            end
            return return_value;
        end
    endfunction

    always @(posedge iclk)begin
        if (new_tapps_r1)begin
            index_max_edge[0]  <= msb_index(valid_edge_w[(`NUM_TAPPS-3)/8:0]);
        end 
    end
    always @(posedge iclk)begin
        if (new_tapps_r1)begin
            index_max_edge[1]  <= msb_index(valid_edge_w[((`NUM_TAPPS-3)/8)*2:(`NUM_TAPPS-3)/8]) ;
        end
    end
    always @(posedge iclk)begin
        if (new_tapps_r1)begin
            index_max_edge[2]  <= msb_index(valid_edge_w[(((`NUM_TAPPS-3)/8)*3):((`NUM_TAPPS-3)/8*2)]); 
        end
    end
    always @(posedge iclk)begin
        if (new_tapps_r1)begin
            index_max_edge[3]  <= msb_index(valid_edge_w[(((`NUM_TAPPS-3)/8)*4):((`NUM_TAPPS-3)/8*3)]); 
        end
    end
    always @(posedge iclk)begin
        if (new_tapps_r1)begin
            index_max_edge[4]  <= msb_index(valid_edge_w[(((`NUM_TAPPS-3)/8)*5):((`NUM_TAPPS-3)/8*4)]); 
        end
    end
    always @(posedge iclk)begin
        if (new_tapps_r1)begin
            index_max_edge[5]  <= msb_index(valid_edge_w[(((`NUM_TAPPS-3)/8)*6):((`NUM_TAPPS-3)/8*5)]); 
        end
    end
    always @(posedge iclk)begin
        if (new_tapps_r1)begin
            index_max_edge[6]  <= msb_index(valid_edge_w[(((`NUM_TAPPS-3)/8)*7):((`NUM_TAPPS-3)/8*6)]); 
        end  
    end
    always @(posedge iclk)begin
        if (new_tapps_r1)begin
            index_max_edge[7]  <= msb_index(valid_edge_w[(((`NUM_TAPPS-3)/8)*8):((`NUM_TAPPS-3)/8*7)]); 
        end
    end
/*    always @(posedge iclk)begin
        if (new_tapps_r2)begin
            val_max_edge[0] <= index_max_edge[0];
            val_max_edge[1] <= index_max_edge[1]+((`NUM_TAPPS-3)/8);
            val_max_edge[2] <= index_max_edge[2]+(((`NUM_TAPPS-3)/8)*2);
            val_max_edge[3] <= index_max_edge[3]+(((`NUM_TAPPS-3)/8)*3);
        end
    end
    always @(posedge iclk)begin
        if (new_tapps_r2)begin
            val_max_edge[4] <= index_max_edge[4]+(((`NUM_TAPPS-3)/8)*4);
            val_max_edge[5] <= index_max_edge[5]+(((`NUM_TAPPS-3)/8)*5);
            val_max_edge[6] <= index_max_edge[6]+(((`NUM_TAPPS-3)/8)*6);
            val_max_edge[7] <= index_max_edge[7]+(((`NUM_TAPPS-3)/8)*7);
        end
    end*/
    always @(posedge iclk)begin 
        if(new_tapps_r2)begin
            if(index_max_edge[7][10])begin
                tapped_stop_val <= index_max_edge[7][9:0]+(((`NUM_TAPPS-3)/8)*7);
                new_value <= 1'b1;
            end 
            else if (index_max_edge[6][10])begin
                tapped_stop_val <= index_max_edge[6][9:0]+(((`NUM_TAPPS-3)/8)*6);
                new_value <= 1'b1;
            end
            else if (index_max_edge[5][10]) begin
                tapped_stop_val <= index_max_edge[5][9:0]+(((`NUM_TAPPS-3)/8)*5);
                new_value <= 1'b1;
            end 
            else if (index_max_edge[4][10])begin   
                tapped_stop_val <= index_max_edge[4][9:0]+(((`NUM_TAPPS-3)/8)*4);
                new_value <= 1'b1;
            end
            else if (index_max_edge[3][10])begin
                tapped_stop_val <= index_max_edge[3][9:0]+(((`NUM_TAPPS-3)/8)*3);
                new_value <= 1'b1;
            end    
            else if (index_max_edge[2][10])begin
                tapped_stop_val <= index_max_edge[2][9:0]+(((`NUM_TAPPS-3)/8)*2);
                new_value <= 1'b1;
            end
            else if (index_max_edge[1][10])begin
                tapped_stop_val <= index_max_edge[1][9:0]+((`NUM_TAPPS-3)/8);
                new_value <= 1'b1;
            end 
            else if (index_max_edge[0][10])begin
                 tapped_stop_val <= index_max_edge[0][9:0];
                 new_value <= 1'b1;
            end 
            else begin
                new_value <= 1'b0;
            end
        end else begin
            new_value <= 1'b0;
        end
    end
/*    always @(posedge iclk)begin
        if (new_tapps_r3)begin
            if(val_max_edge[7] != 0)begin 
                val_max_edge_2[1] <= val_max_edge[7]; 
            end
            else if(val_max_edge[6]!= 0)begin 
             val_max_edge_2[1] <= val_max_edge[6]; 
            end
            else if(val_max_edge[5]!= 0)begin
             val_max_edge_2[1] <= val_max_edge[5]; 
            end
            else if(val_max_edge[4]!= 0) begin
                 val_max_edge_2[1] <= val_max_edge[4]; 
            end
        end
    end         
    always @(posedge iclk)begin
        if (new_tapps_r3)begin
            if(val_max_edge[3] != 0)begin 
                val_max_edge_2[0] <= val_max_edge[3]; 
            end
            else if(val_max_edge[2]!= 0)begin 
             val_max_edge_2[0] <= val_max_edge[2]; 
            end
            else if(val_max_edge[1]!= 0)begin
             val_max_edge_2[0] <= val_max_edge[1]; 
            end
            else if(val_max_edge[0]!= 0) begin
                 val_max_edge_2[0] <= val_max_edge[0]; 
            end
        end
    end      */
/*    always @(posedge iclk)begin
        if (new_tapps_r4)begin
            if (val_max_edge_2[1]!=0)begin
                tapped_stop_val <= val_max_edge_2[1];
                new_value <= 1'b1;
            end
            else if (val_max_edge_2[0] != 0) begin
                tapped_stop_val <= val_max_edge_2[0];
                new_value <= 1'b1;
            end 
            else begin
                new_value <= 1'b0;
            end
        end else 
            new_value <= 1'b0;
    end
*/

    

endmodule
