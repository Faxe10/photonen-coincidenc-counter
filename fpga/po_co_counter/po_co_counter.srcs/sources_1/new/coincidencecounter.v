`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2025 11:03:59 PM
// Design Name: 
// Module Name: coincidencecounter
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


module coincidencecounter(
    input reset,
    input clk_250mhz,
    input new_time_ch1,
    input new_time_ch2,
    input new_time_ch3,
    input new_time_ch4,
    input new_time_ch5,
    input new_time_ch6,
    input new_time_ch7,
    input new_time_ch8,
    
    input [20:0]time_window,
    input [59:0]time_ch1,
    input [59:0]time_ch2,
    input [59:0]time_ch3,
    input [59:0]time_ch4,
    input [59:0]time_ch5,
    input [59:0]time_ch6,
    input [59:0]time_ch7,
    input [59:0]time_ch8,
    output reg[21:0]count1_5_out,count1_6_out,count1_7_out,count1_8_out,
    output reg[21:0]count2_5_out,count2_6_out,count2_7_out,count2_8_out,
    output reg[21:0]count3_5_out,count3_6_out,count3_7_out,count3_8_out,
    output reg[21:0]count4_5_out,count4_6_out,count4_7_out,count4_8_out
    );
    
    reg [47:0] time_ch1_r;
    reg [47:0] time_ch2_r;
    reg [47:0] time_ch3_r;
    reg [47:0] time_ch4_r;
    reg [47:0] time_ch5_r;
    reg [47:0] time_ch6_r;
    reg [47:0] time_ch7_r;
    reg [47:0] time_ch8_r;
    reg [20:0] time_window1_5, time_window1_6, time_window1_7,time_window1_8;
    reg [20:0] time_window2_5, time_window2_6, time_window2_7,time_window2_8;
    reg [20:0] time_window3_5, time_window3_6, time_window3_7,time_window3_8;
    reg [20:0] time_window4_5, time_window4_6, time_window4_7,time_window4_8;    
    
    reg new_time_ch1_r;
    reg new_time_ch2_r;
    reg new_time_ch3_r;   
    reg new_time_ch4_r;
    reg new_time_ch5_r;
    reg new_time_ch6_r;
    reg new_time_ch7_r;
    reg new_time_ch8_r;
    
    reg inc1_5,inc1_6,inc1_7,inc1_8;
    reg inc2_5,inc2_6,inc2_7,inc2_8;
    reg inc3_5,inc3_6,inc3_7,inc3_8;
    reg inc4_5,inc4_6,inc4_7,inc4_8;
    
    reg signed [48:0] diff1_5,diff1_6,diff1_7,diff1_8;
    reg signed [48:0] diff2_5,diff2_6,diff2_7,diff2_8;
    reg signed [48:0] diff3_5,diff3_6,diff3_7,diff3_8;
    reg signed [48:0] diff4_5,diff4_6,diff4_7,diff4_8;      
    
    reg signed [48:0] diff1_5_r,diff1_6_r,diff1_7_r,diff1_8_r;
    reg signed [48:0] diff2_5_r,diff2_6_r,diff2_7_r,diff2_8_r;
    reg signed [48:0] diff3_5_r,diff3_6_r,diff3_7_r,diff3_8_r;
    reg signed [48:0] diff4_5_r,diff4_6_r,diff4_7_r,diff4_8_r;
    
    reg [47:0] pos_diff1_5, pos_diff1_6,pos_diff1_7,pos_diff1_8;
    reg [47:0] pos_diff2_5, pos_diff2_6,pos_diff2_7,pos_diff2_8;
    reg [47:0] pos_diff3_5, pos_diff3_6,pos_diff3_7,pos_diff3_8;
    reg [47:0] pos_diff4_5, pos_diff4_6,pos_diff4_7,pos_diff4_8;
    
    reg [47:0] pos_diff1_5_r, pos_diff1_6_r,pos_diff1_7_r,pos_diff1_8_r;
    reg [47:0] pos_diff2_5_r, pos_diff2_6_r,pos_diff2_7_r,pos_diff2_8_r;
    reg [47:0] pos_diff3_5_r, pos_diff3_6_r,pos_diff3_7_r,pos_diff3_8_r;
    reg [47:0] pos_diff4_5_r, pos_diff4_6_r,pos_diff4_7_r,pos_diff4_8_r;
    
    reg [47:0] pos_neg_diff1_5,pos_neg_diff1_6,pos_neg_diff1_7,pos_neg_diff1_8;
    reg [47:0] pos_neg_diff2_5,pos_neg_diff2_6,pos_neg_diff2_7,pos_neg_diff2_8;
    reg [47:0] pos_neg_diff3_5,pos_neg_diff3_6,pos_neg_diff3_7,pos_neg_diff3_8;
    reg [47:0] pos_neg_diff4_5,pos_neg_diff4_6,pos_neg_diff4_7,pos_neg_diff4_8;
    
    reg new_diff1_5,new_diff1_6,new_diff1_7,new_diff1_8;
    reg new_diff2_5,new_diff2_6,new_diff2_7,new_diff2_8;
    reg new_diff3_5,new_diff3_6,new_diff3_7,new_diff3_8;
    reg new_diff4_5,new_diff4_6,new_diff4_7,new_diff4_8;
    
    reg new_diff1_5_r,new_diff1_6_r,new_diff1_7_r,new_diff1_8_r;
    reg new_diff2_5_r,new_diff2_6_r,new_diff2_7_r,new_diff2_8_r;
    reg new_diff3_5_r,new_diff3_6_r,new_diff3_7_r,new_diff3_8_r;
    reg new_diff4_5_r,new_diff4_6_r,new_diff4_7_r,new_diff4_8_r;
    
    reg new_pos_diff1_5,new_pos_diff1_6,new_pos_diff1_7,new_pos_diff1_8;
    reg new_pos_diff2_5,new_pos_diff2_6,new_pos_diff2_7,new_pos_diff2_8;
    reg new_pos_diff3_5,new_pos_diff3_6,new_pos_diff3_7,new_pos_diff3_8;
    reg new_pos_diff4_5,new_pos_diff4_6,new_pos_diff4_7,new_pos_diff4_8;
    
    reg new_pos_diff1_5_r,new_pos_diff1_6_r,new_pos_diff1_7_r,new_pos_diff1_8_r;
    reg new_pos_diff2_5_r,new_pos_diff2_6_r,new_pos_diff2_7_r,new_pos_diff2_8_r;
    reg new_pos_diff3_5_r,new_pos_diff3_6_r,new_pos_diff3_7_r,new_pos_diff3_8_r;
    reg new_pos_diff4_5_r,new_pos_diff4_6_r,new_pos_diff4_7_r,new_pos_diff4_8_r;
    
    reg new_small_diff1_5,new_small_diff1_6,new_small_diff1_7,new_small_diff1_8;
    reg new_small_diff2_5,new_small_diff2_6,new_small_diff2_7,new_small_diff2_8;
    reg new_small_diff3_5,new_small_diff3_6,new_small_diff3_7,new_small_diff3_8;
    reg new_small_diff4_5,new_small_diff4_6,new_small_diff4_7,new_small_diff4_8;
    
    reg [20:0] small_diff1_5,small_diff1_6,small_diff1_7,small_diff1_8;
    reg [20:0] small_diff2_5,small_diff2_6,small_diff2_7,small_diff2_8;
    reg [20:0] small_diff3_5,small_diff3_6,small_diff3_7,small_diff3_8;
    reg [20:0] small_diff4_5,small_diff4_6,small_diff4_7,small_diff4_8;
    
    reg diff1_5_pos,diff1_6_pos,diff1_7pos, diff1_8_pos;
    reg diff2_5_pos,diff2_6_pos,diff2_7_pos,diff2_8_pos;
    reg diff3_5_pos,diff3_6_pos,diff3_7_pos,diff3_8_pos;
    reg diff4_5_pos,diff4_6_pos,diff4_7_pos,diff4_8_pos;
    
 
    reg[21:0]count1_5,count1_6,count1_7,count1_8;
    reg[21:0]count2_5,count2_6,count2_7,count2_8;
    reg[21:0]count3_5,count3_6,count3_7,count3_8;
    reg[21:0]count4_5,count4_6,count4_7,count4_8;
    reg new_small_diff,new_small_diff_r;
    reg [20:0] small_diff,small_diff_r;
    reg new_diff,new_diff_old;
    reg new_pos_diff, new_pos_diff_r;
    
    (* max_fanout = 8 *) reg [20:0] time_window_r;
    always @(posedge clk_250mhz) time_window_r <= time_window;
    always @(posedge clk_250mhz) time_ch1_r <= time_ch1[47:0];
    always @(posedge clk_250mhz) time_ch2_r <= time_ch2[47:0];
    always @(posedge clk_250mhz) time_ch3_r <= time_ch3[47:0];
    always @(posedge clk_250mhz) time_ch4_r <= time_ch4[47:0];
    always @(posedge clk_250mhz) time_ch5_r <= time_ch5[47:0];
    always @(posedge clk_250mhz) time_ch6_r <= time_ch6[47:0];
    always @(posedge clk_250mhz) time_ch7_r <= time_ch7[47:0];
    always @(posedge clk_250mhz) time_ch8_r <= time_ch8[47:0];
    always @(posedge clk_250mhz) new_time_ch1_r <= new_time_ch1;  
    always @(posedge clk_250mhz) new_time_ch2_r <= new_time_ch2;         
    always @(posedge clk_250mhz) new_time_ch3_r <= new_time_ch3;         
    always @(posedge clk_250mhz) new_time_ch4_r <= new_time_ch4;         
    always @(posedge clk_250mhz) new_time_ch5_r <= new_time_ch5;         
    always @(posedge clk_250mhz) new_time_ch6_r <= new_time_ch6;         
    always @(posedge clk_250mhz) new_time_ch7_r <= new_time_ch7;         
    always @(posedge clk_250mhz) new_time_ch8_r <= new_time_ch8; 
    
    always @(posedge clk_250mhz) pos_neg_diff1_5 <= -diff1_5;
    always @(posedge clk_250mhz) pos_neg_diff1_6 <= -diff1_6;
    always @(posedge clk_250mhz) pos_neg_diff1_7 <= -diff1_7;
    always @(posedge clk_250mhz) pos_neg_diff1_8 <= -diff1_8;
    
    always @(posedge clk_250mhz) pos_neg_diff2_5 <= -diff2_5;
    always @(posedge clk_250mhz) pos_neg_diff2_6 <= -diff2_6;
    always @(posedge clk_250mhz) pos_neg_diff2_7 <= -diff2_7;
    always @(posedge clk_250mhz) pos_neg_diff2_8 <= -diff2_8;    
   
    always @(posedge clk_250mhz) pos_neg_diff3_5 <= -diff3_5;
    always @(posedge clk_250mhz) pos_neg_diff3_6 <= -diff3_6;
    always @(posedge clk_250mhz) pos_neg_diff3_7 <= -diff3_7;
    always @(posedge clk_250mhz) pos_neg_diff3_8 <= -diff3_8;    
  
    always @(posedge clk_250mhz) pos_neg_diff4_5 <= -diff4_5;
    always @(posedge clk_250mhz) pos_neg_diff4_6 <= -diff4_6;
    always @(posedge clk_250mhz) pos_neg_diff4_7 <= -diff4_7;
    always @(posedge clk_250mhz) pos_neg_diff4_8 <= -diff4_8;    
        
    
    always @(posedge clk_250mhz) begin
            count1_5_out <= count1_5;
            count1_6_out <= count1_6;
            count1_7_out <= count1_7;
            count1_8_out <= count1_8;
    end
    always @(posedge clk_250mhz) begin
            count2_5_out <= count2_5;
            count2_6_out <= count2_6;
            count2_7_out <= count2_7;
            count2_8_out <= count2_8;
    end
    always @(posedge clk_250mhz) begin
            count3_5_out <= count3_5;
            count3_6_out <= count3_6;
            count3_7_out <= count3_7;
            count3_8_out <= count3_8;
    end                  
    
    always @(posedge clk_250mhz) begin
            count4_5_out <= count4_5;
            count4_6_out <= count4_6;
            count4_7_out <= count4_7;
            count4_8_out <= count4_8;
    end
    // cal diff 
    always @(posedge clk_250mhz) begin
        diff1_5 <= time_ch1_r - time_ch5_r;
        if (new_time_ch1_r | new_time_ch5_r) begin   
            new_diff1_5 <= 1;
        end else
            new_diff1_5 <= 0;
    end
    
    always @(posedge clk_250mhz) begin
        diff1_6 <= time_ch1_r - time_ch6_r;
        if (new_time_ch1_r | new_time_ch6_r) begin
            new_diff1_6 <= 1;
        end else
            new_diff1_6 <= 0;
    end
     always @(posedge clk_250mhz) begin
        diff1_7 <= time_ch1_r - time_ch7_r;
        if (new_time_ch1_r | new_time_ch7_r) begin   
            new_diff1_7 <= 1;
        end else
            new_diff1_7 <= 0;
    end
     always @(posedge clk_250mhz) begin
        diff1_8 <= time_ch1_r - time_ch8_r;
        if (new_time_ch1_r | new_time_ch8_r) begin 
            new_diff1_8 <= 1;
        end else
            new_diff1_8 <= 0;
    end
    always @(posedge clk_250mhz) begin
        diff2_5 <= time_ch2_r - time_ch5_r;
        if (new_time_ch2_r | new_time_ch5_r) begin
            new_diff2_5 <= 1;
        end else
            new_diff2_5 <= 0;
    end
    
    always @(posedge clk_250mhz) begin
        diff2_6 <= time_ch2_r - time_ch6_r;  
        if (new_time_ch2_r | new_time_ch6_r) begin 
            new_diff2_6 <= 1;
        end else
            new_diff2_6 <= 0;
    end
     always @(posedge clk_250mhz) begin
        diff2_7 <= time_ch2_r - time_ch7_r;   
        if (new_time_ch2_r | new_time_ch7_r) begin
            new_diff2_7 <= 1;
        end else
            new_diff2_7 <= 0;
    end
     always @(posedge clk_250mhz) begin
        diff2_8 <= time_ch2_r - time_ch8_r; 
        if (new_time_ch2_r | new_time_ch8_r) begin  
            new_diff2_8 <= 1;
        end else
            new_diff2_8 <= 0;
    end
    always @(posedge clk_250mhz) begin
        diff3_5 <= time_ch3_r - time_ch5_r;
        if (new_time_ch3_r | new_time_ch5_r) begin   
            new_diff3_5 <= 1;
        end else
            new_diff3_5 <= 0;
    end
    always @(posedge clk_250mhz) begin
        diff3_6 <= time_ch3_r - time_ch6_r;
        if (new_time_ch3_r | new_time_ch6_r) begin   
            new_diff3_6 <= 1;
        end else
            new_diff3_6 <= 0;
    end
    always @(posedge clk_250mhz) begin
        diff3_7 <= time_ch3_r - time_ch7_r; 
        if (new_time_ch3_r | new_time_ch7_r) begin  
            new_diff3_7 <= 1;
        end else
            new_diff3_7 <= 0;
    end
    always @(posedge clk_250mhz) begin
        diff3_8 <= time_ch3_r - time_ch8_r;
        if (new_time_ch3_r | new_time_ch8_r) begin   
            new_diff3_8 <= 1;
        end else
            new_diff3_8 <= 0;
    end
        always @(posedge clk_250mhz) begin
        diff4_5 <= time_ch4_r - time_ch5_r;
        if (new_time_ch4_r | new_time_ch5_r) begin    
            new_diff4_5 <= 1;
        end else
            new_diff4_5 <= 0;
    end
    
    always @(posedge clk_250mhz) begin
        diff4_6 <= time_ch4_r - time_ch6_r; 
        if (new_time_ch4_r | new_time_ch6_r) begin 
            new_diff4_6 <= 1;
        end else
            new_diff4_6 <= 0;
    end
    always @(posedge clk_250mhz) begin
        diff4_7 <= time_ch4_r - time_ch7_r;   
        if (new_time_ch4_r | new_time_ch7_r) begin 
            new_diff4_7 <= 1;
        end else
            new_diff4_7 <= 0;
    end
    always @(posedge clk_250mhz) begin
        diff4_8 <= time_ch4_r - time_ch8_r;  
        if (new_time_ch4_r | new_time_ch8_r) begin  
            new_diff4_8 <= 1;
        end else
            new_diff4_8 <= 0;
    end
    
    // make diff positiv***********************************************************************************************
    //ch1
    always @(posedge clk_250mhz)begin
        new_diff1_5_r <= new_diff1_5;
        diff1_5_r <= diff1_5;
        if (new_diff1_5_r)begin
            if (diff1_5_r[48] == 0)begin
                pos_diff1_5 <= diff1_5_r;
            end else
                pos_diff1_5 <= pos_neg_diff1_5;
            new_pos_diff1_5 <= 1;
        end else
            new_pos_diff1_5 <= 0;
     end
     
     always @(posedge clk_250mhz)begin
        new_diff1_6_r <= new_diff1_6;
        diff1_6_r <= diff1_6;
        if (new_diff1_6_r)begin
            if (diff1_6_r[48] == 0)begin
                pos_diff1_6 <= diff1_6_r;
            end else
                pos_diff1_6 <= pos_neg_diff1_6;
            new_pos_diff1_6 <= 1;
        end else
            new_pos_diff1_6 <= 0;
     end 
     
     always @(posedge clk_250mhz)begin
        new_diff1_7_r <= new_diff1_7;
        diff1_7_r <= diff1_7;
        if (new_diff1_7_r)begin
            if (diff1_7_r[48] == 0)begin
                pos_diff1_7 <= diff1_7_r;
            end else
                pos_diff1_7 <= pos_neg_diff1_7;
            new_pos_diff1_7 <= 1;
        end else
            new_pos_diff1_7 <= 0;
     end
     
     always @(posedge clk_250mhz)begin
        new_diff1_8_r <= new_diff1_8;
        diff1_8_r <= diff1_8;
        if (new_diff1_8_r)begin
            if (diff1_8_r[48] == 0)begin
                pos_diff1_8 <= diff1_8_r;
            end else
                pos_diff1_8 <= pos_neg_diff1_8;
            new_pos_diff1_8 <= 1;
        end else
            new_pos_diff1_8 <= 0;
     end
     //ch2
     always @(posedge clk_250mhz)begin
        new_diff2_5_r <= new_diff2_5;
        diff2_5_r <= diff2_5;
        if (new_diff2_5_r)begin
            if (diff2_5_r[48] == 0)begin
                pos_diff2_5 <= diff2_5_r;
            end else
                pos_diff2_5 <= pos_neg_diff2_5;
            new_pos_diff2_5 <= 1;
        end else
            new_pos_diff2_5 <= 0;
     end
     
     always @(posedge clk_250mhz)begin
        new_diff2_6_r <= new_diff2_6;
        diff2_6_r <= diff2_6;
        if (new_diff2_6_r)begin
            if (diff2_6_r[48] == 0)begin
                pos_diff2_6 <= diff2_6_r;
            end else
                pos_diff2_6 <= pos_neg_diff2_6;
            new_pos_diff2_6 <= 1;
        end else
            new_pos_diff2_6 <= 0;
     end 
     
     always @(posedge clk_250mhz)begin
        new_diff2_7_r <= new_diff2_7;
        diff2_7_r <= diff2_7;
        if (new_diff2_7_r)begin
            if (diff2_7_r[48] == 0)begin
                pos_diff2_7 <= diff2_7_r;
            end else
                pos_diff2_7 <= pos_neg_diff2_7;
            new_pos_diff2_7 <= 1;
        end else
            new_pos_diff2_7 <= 0;
     end
     
     always @(posedge clk_250mhz)begin
        new_diff2_8_r <= new_diff2_8;
        diff2_8_r <= diff2_8;
        if (new_diff2_8_r)begin
            if (diff2_8_r[48] == 0)begin
                pos_diff2_8 <= diff2_8_r;
            end else
                pos_diff2_8 <= pos_neg_diff2_8;
            new_pos_diff2_8 <= 1;
        end else
            new_pos_diff2_8 <= 0;
     end
     //ch3   
     always @(posedge clk_250mhz)begin
        new_diff3_5_r <= new_diff3_5;
        diff3_5_r <= diff3_5;
        if (new_diff3_5_r)begin
            if (diff3_5_r[48] == 0)begin
                pos_diff3_5 <= diff3_5_r;
            end else
                pos_diff3_5 <= pos_neg_diff3_5;
            new_pos_diff3_5 <= 1;
        end else
            new_pos_diff3_5 <= 0;
     end
     
     always @(posedge clk_250mhz)begin
        new_diff3_6_r <= new_diff3_6;
        diff3_6_r <= diff3_6;
        if (new_diff3_6_r)begin
            if (diff3_6_r[48] == 0)begin
                pos_diff3_6 <= diff3_6_r;
            end else
                pos_diff3_6 <= pos_neg_diff3_6;
            new_pos_diff3_6 <= 1;
        end else
            new_pos_diff3_6 <= 0;
     end 
     
     always @(posedge clk_250mhz)begin
        new_diff3_7_r <= new_diff3_7;
        diff3_7_r <= diff3_7;
        if (new_diff3_7_r)begin
            if (diff3_7_r[48] == 0)begin
                pos_diff3_7 <= diff3_7_r;
            end else
                pos_diff3_7 <= pos_neg_diff3_7;
            new_pos_diff3_7 <= 1;
        end else
            new_pos_diff3_7 <= 0;
     end
     
     always @(posedge clk_250mhz)begin
        new_diff3_8_r <= new_diff3_8;
        diff3_8_r <= diff3_8;
        if (new_diff3_8_r)begin
            if (diff3_8_r[48] == 0)begin
                pos_diff3_8 <= diff3_8_r;
            end else
                pos_diff3_8 <= pos_neg_diff3_8;
            new_pos_diff3_8 <= 1;
        end else
            new_pos_diff3_8 <= 0;
     end
     //ch4 
     always @(posedge clk_250mhz)begin
        new_diff4_5_r <= new_diff4_5;
        diff4_5_r <= diff4_5;
        if (new_diff4_5_r)begin
            if (diff4_5_r[48] == 0)begin
                pos_diff4_5 <= diff4_5_r;
            end else
                pos_diff4_5 <= pos_neg_diff4_5;
            new_pos_diff4_5 <= 1;
        end else
            new_pos_diff4_5 <= 0;
     end
     
     always @(posedge clk_250mhz)begin
        new_diff4_6_r <= new_diff4_6;
        diff4_6_r <= diff4_6; 
        if (new_diff4_6_r)begin
            if (diff4_6_r[48] == 0)begin
                pos_diff4_6 <= diff4_6_r;
            end else
                pos_diff4_6 <= pos_neg_diff4_6;
            new_pos_diff4_6 <= 1;
        end else
            new_pos_diff4_6 <= 0;
     end 
     
     always @(posedge clk_250mhz)begin
        new_diff4_7_r <= new_diff4_7;
        diff4_7_r <= diff4_7;
        if (new_diff4_7_r)begin
            if (diff4_7_r[48] == 0)begin
                pos_diff4_7 <= diff4_7_r;
            end else
                pos_diff4_7 <= pos_neg_diff4_7;
            new_pos_diff4_7 <= 1;
        end else
            new_pos_diff4_7 <= 0;
            new_pos_diff4_7 <= 0;
     end
     
     always @(posedge clk_250mhz)begin
        new_diff4_8_r <= new_diff4_8;
        diff4_8_r <= diff4_8; 
        if (new_diff4_8_r)begin
            if (diff4_8_r[48] == 0)begin
                pos_diff4_8 <= diff4_8_r;
            end else
                pos_diff4_8 <= pos_neg_diff4_8;
            new_pos_diff4_8 <= 1;
        end else
            new_pos_diff4_8 <= 0;
     end
       
// check small diff
//ch1     
     always @(posedge clk_250mhz)begin
        pos_diff1_5_r <= pos_diff1_5;
        new_pos_diff1_5_r <= new_pos_diff1_5;
        if (new_pos_diff1_5_r) begin
            if (pos_diff1_5_r[47:20] == 0)begin
                new_small_diff1_5 <= 1;
                small_diff1_5 <= pos_diff1_5_r[20:0];
            end else
                new_small_diff1_5 <= 0;
        end else
            new_small_diff1_5 <= 0;
     end
     always @(posedge clk_250mhz)begin
        new_pos_diff1_6_r <= new_pos_diff1_6;
        pos_diff1_6_r <= pos_diff1_6;
        small_diff1_6 <= pos_diff1_6_r[20:0];       
        if (new_pos_diff1_6_r) begin
            if (pos_diff1_6_r[47:20] == 0)begin
                new_small_diff1_6 <= 1;
            end else
                new_small_diff1_6 <= 0;
        end else
            new_small_diff1_6 <= 0;
     end
     always @(posedge clk_250mhz)begin
        new_pos_diff1_7_r <= new_pos_diff1_7;
        pos_diff1_7_r <= pos_diff1_7;
        small_diff1_7 <= pos_diff1_7_r[20:0];
        if (new_pos_diff1_7_r) begin
            if (pos_diff1_7_r[47:20] == 0)begin
                new_small_diff1_7 <= 1;
            end else
                new_small_diff1_7 <= 0;
        end else
            new_small_diff1_7 <= 0;
     end
     always @(posedge clk_250mhz)begin
        new_pos_diff1_8_r <= new_pos_diff1_8;
        pos_diff1_8_r <= pos_diff1_8;
        small_diff1_8 <= pos_diff1_8_r[20:0];
        if (new_pos_diff1_8_r) begin
            if (pos_diff1_8_r[47:20] == 0)begin
                new_small_diff1_8 <= 1;
            end else
                new_small_diff1_8 <= 0;
        end else
            new_small_diff1_8 <= 0;
     end
     //ch2 
     always @(posedge clk_250mhz)begin
        new_pos_diff2_5_r <= new_pos_diff2_5;
        pos_diff2_5_r <= pos_diff2_5;  
        small_diff2_5 <= pos_diff2_5_r[20:0];   
        if (new_pos_diff2_5_r) begin
            if (pos_diff2_5_r[47:20] == 0)begin
                new_small_diff2_5 <= 1;
            end else
                new_small_diff2_5 <= 0;
        end else
            new_small_diff2_5 <= 0;
     end
     always @(posedge clk_250mhz)begin
        new_pos_diff2_6_r <= new_pos_diff2_6;
        pos_diff2_6_r <= pos_diff2_6;
        small_diff2_6 <= pos_diff2_6_r[20:0];
        if (new_pos_diff2_6_r) begin
            if (pos_diff2_6_r[47:20] == 0)begin
                new_small_diff2_6 <= 1;
            end else
                new_small_diff2_6 <= 0;
        end else
            new_small_diff2_6 <= 0;
     end
     always @(posedge clk_250mhz)begin
        new_pos_diff2_7_r <= new_pos_diff2_7;
        pos_diff2_7_r <= pos_diff2_7;
        small_diff2_7 <= pos_diff2_7_r[20:0];
        if (new_pos_diff2_7_r) begin
            if (pos_diff2_7_r[47:20] == 0)begin
                new_small_diff2_7 <= 1;
            end else
                new_small_diff2_7 <= 0;
        end else
            new_small_diff2_7 <= 0;
     end
     always @(posedge clk_250mhz)begin
        new_pos_diff2_8_r <= new_pos_diff2_8;
        pos_diff2_8_r <= pos_diff2_8;
        small_diff2_8 <= pos_diff2_8_r[20:0];
        if (new_pos_diff2_8_r) begin
            if (pos_diff2_8_r[47:20] == 0)begin
                new_small_diff2_8 <= 1; 
            end else
                new_small_diff2_8 <= 0;
        end else
            new_small_diff2_8 <= 0;
     end
     //ch3
     always @(posedge clk_250mhz)begin
        new_pos_diff3_5_r <= new_pos_diff3_5;
        pos_diff3_5_r <= pos_diff3_5;
        small_diff3_5 <= pos_diff3_5_r[20:0];
        if (new_pos_diff3_5_r) begin
            if (pos_diff3_5_r[47:20] == 0)begin
                new_small_diff3_5 <= 1;
            end else
                new_small_diff3_5 <= 0;
        end else
            new_small_diff3_5 <= 0;
     end
     always @(posedge clk_250mhz)begin
        new_pos_diff3_6_r <= new_pos_diff3_6;
        pos_diff3_6_r <= pos_diff3_6;
        small_diff3_6 <= pos_diff3_6_r[20:0];
        if (new_pos_diff3_6_r) begin
            if (pos_diff3_6_r[47:20] == 0)begin
                new_small_diff3_6 <= 1;
            end else
                new_small_diff3_6 <= 0;
        end else
            new_small_diff3_6 <= 0;
     end
     always @(posedge clk_250mhz)begin
        new_pos_diff3_7_r <= new_pos_diff3_7;
        pos_diff3_7_r <= pos_diff3_7_r;
        small_diff3_7 <= pos_diff3_7_r[20:0];
        if (new_pos_diff3_7_r) begin
            if (pos_diff3_7_r[47:20] == 0)begin
                new_small_diff3_7 <= 1;
            end else
                new_small_diff3_7 <= 0;
        end else
            new_small_diff3_7 <= 0;
     end
     always @(posedge clk_250mhz)begin
        new_pos_diff3_8_r <= new_pos_diff3_8;
        pos_diff3_8_r <= pos_diff3_8;
        small_diff3_8 <= pos_diff3_8_r[20:0];
        if (new_pos_diff3_8_r) begin
            if (pos_diff3_8_r[47:20] == 0)begin
                new_small_diff3_8 <= 1;
            end else
                new_small_diff3_8 <= 0;
        end else
            new_small_diff3_8 <= 0;
     end
     //ch4
     always @(posedge clk_250mhz)begin
        new_pos_diff4_5_r <= new_pos_diff4_5;
        pos_diff4_5_r <= pos_diff4_5; 
        small_diff4_5 <= pos_diff4_5_r[20:0];
        if (new_pos_diff4_5_r) begin
            if (pos_diff4_5_r[47:20] == 0)begin
                new_small_diff4_5 <= 1;
            end else
                new_small_diff4_5 <= 0;
        end else
            new_small_diff4_5 <= 0;
     end
     always @(posedge clk_250mhz)begin
        new_pos_diff4_6_r <= new_pos_diff4_6;
        pos_diff4_6_r <= pos_diff4_6;
        
        if (new_pos_diff4_6_r) begin
            if (pos_diff4_6_r[47:20] == 0)begin
                new_small_diff4_6 <= 1;
            end else
                new_small_diff4_6 <= 0;
        end else
            new_small_diff4_6 <= 0;
     end
     always @(posedge clk_250mhz)begin
        new_pos_diff4_7_r <= new_pos_diff4_7;
        pos_diff4_7_r <= pos_diff4_7;
        small_diff4_7 <= pos_diff4_7_r[20:0];
        if (new_pos_diff4_7_r) begin
            if (pos_diff4_7_r[47:20] == 0)begin
                new_small_diff4_7 <= 1;
            end else
                new_small_diff4_7 <= 0;
        end else
            new_small_diff4_7 <= 0;
     end
     always @(posedge clk_250mhz)begin
        new_pos_diff4_8_r <= new_pos_diff4_8;
        pos_diff4_8 <= new_pos_diff4_8;
        small_diff4_8 <= pos_diff4_8_r[20:0];
        if (new_pos_diff4_8_r) begin
            if (pos_diff4_8_r[47:20] == 0)begin
                new_small_diff4_8 <= 1;
            end else
                new_small_diff4_8 <= 0;
        end else
            new_small_diff4_8 <= 0;
     end
     // check if coincidence ***********************************************************************
     //ch1
     always @(posedge clk_250mhz)begin
        if (new_small_diff1_5) begin
            if (small_diff1_5 < time_window_r) begin
             //       count <= count + 1;
                inc1_5 <=  1;
            end else begin
                inc1_5 <= 0;
            end
        end else begin
            inc1_5 <= 0;
        end
      end
      always @(posedge clk_250mhz)begin
        if (new_small_diff1_6) begin
            if (small_diff1_6 < time_window_r) begin
             //       count <= count + 1;
                inc1_6 <=  1;
            end else begin
                inc1_6 <= 0;
            end
        end else begin 
            inc1_6 <= 0;
        end
      end
      always @(posedge clk_250mhz)begin
        if (new_small_diff1_7) begin
            if (small_diff1_7 < time_window_r) begin
             //       count <= count + 1;
                inc1_7 <=  1;
            end else begin
                inc1_7 <= 0;
            end
        end else begin 
            inc1_7 <= 0;
        end
      end
      always @(posedge clk_250mhz)begin
        if (new_small_diff1_8) begin
            if (small_diff1_8 < time_window_r) begin
             //       count <= count + 1;
                inc1_8 <=  1;
            end else begin
                inc1_8 <= 0;
            end
        end else begin 
            inc1_8 <= 0;
        end
      end
      //ch2
      always @(posedge clk_250mhz)begin
        if (new_small_diff2_5) begin
            if (small_diff2_5 < time_window_r) begin
             //       count <= count + 1;
                inc2_5 <=  1;
            end else begin
                inc2_5 <= 0;
            end
        end else begin 
            inc2_5 <= 0;
        end
      end
      always @(posedge clk_250mhz)begin
        if (new_small_diff2_6) begin
            if (small_diff2_6 < time_window_r) begin
             //       count <= count + 1;
                inc2_6 <=  1;
            end else begin
                inc2_6 <= 0;
            end
        end else begin 
            inc2_6 <= 0;
        end
      end
      always @(posedge clk_250mhz)begin
        if (new_small_diff2_7) begin
            if (small_diff2_7 < time_window_r) begin
             //       count <= count + 1;
                inc2_7 <=  1;
            end else begin
                inc2_7 <= 0;
            end
        end else begin 
            inc2_7 <= 0;
        end
      end
      always @(posedge clk_250mhz)begin
        if (new_small_diff2_8) begin
            if (small_diff2_8 < time_window_r) begin
                inc2_8 <= 1;
            end else begin
                inc2_8 <= 0;
            end 
        end else begin 
            inc2_8 <= 0;
        end
      end
             //       count <= count + 1;

     //ch3
      always @(posedge clk_250mhz)begin
        if (new_small_diff3_5) begin
            if (small_diff3_5 < time_window_r) begin
             //       count <= count + 1;
                inc3_5 <= 1;
            end else begin
                inc3_5 <= 0;
            end 
        end else begin 
            inc3_5 <= 0;
        end
      end
      always @(posedge clk_250mhz)begin
        if (new_small_diff3_6) begin
            if (small_diff3_6 < time_window_r) begin
             //       count <= count + 1;
                       inc3_6 <= 1;
            end else begin
                inc3_6 <= 0;
            end 
        end else begin 
            inc3_6 <= 0;
        end
      end
      always @(posedge clk_250mhz)begin
        if (new_small_diff3_7) begin
            if (small_diff3_7 < time_window_r) begin
             //       count <= count + 1;
                         inc3_7 <= 1;
            end else begin
                inc3_7 <= 0;
            end 
        end else begin 
            inc3_7 <= 0;
        end
      end
      
      always @(posedge clk_250mhz)begin
        if (new_small_diff3_8) begin
            if (small_diff3_8 < time_window_r) begin
             //       count <= count + 1;
                         inc3_8 <= 1;
            end else begin
                inc3_8 <= 0;
            end 
        end else begin 
            inc3_8 <= 0;
        end
      end
      //ch4
      always @(posedge clk_250mhz)begin
        if (new_small_diff4_5) begin
            if (small_diff4_5 < time_window_r) begin
             //       count <= count + 1;
                        inc4_5 <= 1;
            end else begin
                inc4_5 <= 0;
            end 
        end else begin 
            inc4_5 <= 0;
        end
      end
      always @(posedge clk_250mhz)begin
        if (new_small_diff4_6) begin
            if (small_diff4_6 < time_window_r) begin
             //       count <= count + 1;
                                inc4_6 <= 1;
            end else begin
                inc4_6 <= 0;
            end 
        end else begin 
            inc4_6 <= 0;
        end
      end
      always @(posedge clk_250mhz)begin
        if (new_small_diff4_7) begin
            if (small_diff4_7 < time_window_r) begin
             //       count <= count + 1;
                                inc4_7 <= 1;
            end else begin
                inc4_7 <= 0;
            end 
        end else begin 
            inc4_7 <= 0;
        end
      end
      
      always @(posedge clk_250mhz)begin
        if (new_small_diff4_8) begin
            if (small_diff4_8 < time_window_r) begin
             //       count <= count + 1;
                                inc4_8 <= 1;
            end else begin
                inc4_8 <= 0;
            end 
        end else begin 
            inc4_8 <= 0;
        end
      end
      
    always @(posedge clk_250mhz)begin
        if (inc1_5)begin
            count1_5 <= count1_5 + 1;
            
        end
    end
     
    always @(posedge clk_250mhz)begin
        if (inc1_6)begin
            count1_6 <= count1_6 +1;
        end
    end
    
    always @(posedge clk_250mhz)begin
        if (inc1_7)begin
            count1_7 <= count1_7 +1;
        end
    end
  
    always @(posedge clk_250mhz)begin
        if (inc1_8)begin
            count1_8 <= count1_8 + 1;
        end
    end
    
    always @(posedge clk_250mhz)begin
        if(inc2_5)begin
            count2_5 <= count2_5 +1;
        end
    end  
    
    always @(posedge  clk_250mhz) begin
        if(inc2_6)begin
            count2_6 <= count2_6 +1;
        end
    end
    
    always @(posedge clk_250mhz) begin 
        if(inc2_7) begin
            count2_7 <= count2_7 + 1;
        end
    end
    
    always @(posedge clk_250mhz)begin
        if(inc2_8)begin
            count2_8 <= count2_8 + 1;
        end
    end
    always @(posedge clk_250mhz)begin
            if(inc3_5)begin
            count3_5 <= count3_5 +1;
        end
    end  
    
    always @(posedge  clk_250mhz) begin
        if(inc3_6)begin
            count3_6 <= count3_6 +1;
        end
    end
    
    always @(posedge clk_250mhz) begin 
        if(inc3_7) begin
            count3_7 <= count3_7 + 1;
        end
    end
    
    always @(posedge clk_250mhz)begin
        if(inc3_8)begin
            count3_8 <= count3_8 + 1;
        end
    end
    
    always @(posedge clk_250mhz) begin
            if(inc4_5)begin
            count4_5 <= count4_5 +1;
        end
    end  
    
    always @(posedge  clk_250mhz) begin
        if(inc4_6)begin
            count4_6 <= count4_6 +1;
        end
    end
    
    always @(posedge clk_250mhz) begin 
        if(inc4_7) begin
            count4_7 <= count4_7 + 1;
        end
    end
    
    always @(posedge clk_250mhz)begin
        if(inc4_8)begin
            count4_8 <= count4_8 + 1;
        end
    end
    
endmodule


