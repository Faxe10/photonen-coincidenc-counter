`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/31/2025 06:36:26 AM
// Design Name: 
// Module Name: start
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



module start(
//pins 
output  led_green,
output reg led_red,


input ch1,
input ch2,
input ch3,
input ch4,
input ch5,
input ch6,
input ch7,
input ch8,

input clk_250mhz,

input [20:0]delay_ch1,
input [20:0]delay_ch2,
input [20:0]delay_ch3,
input [20:0]delay_ch4,
input [20:0]delay_ch5,
input [20:0]delay_ch6,
input [20:0]delay_ch7,
input [20:0]delay_ch8,

input [31:0]integration_time,
//software
output reset_out,
output reg [21:0] count_ch1,
output reg [21:0] count_ch2,
output reg [21:0] count_ch3,
output reg [21:0] count_ch4,
output reg [21:0] count_ch5,
output reg [21:0] count_ch6,
output reg [21:0] count_ch7,
output reg [21:0] count_ch8,

//output reg [19:0] count_coincidenc,

output reg  [59:0]time_ch1,
output reg  [59:0]time_ch2,
output reg  [59:0]time_ch3,
output reg  [59:0]time_ch4,
output reg  [59:0]time_ch5,
output reg  [59:0]time_ch6,
output reg  [59:0]time_ch7,
output reg  [59:0]time_ch8,

output reg new_time_ch1,
output reg new_time_ch2,
output reg new_time_ch3,
output reg new_time_ch4,
output reg new_time_ch5,
output reg new_time_ch6,
output reg new_time_ch7,
output reg new_time_ch8,

// software monitoring
//wenn noch platz 
output  [20:0]delay_ch1_out,
output  [20:0]delay_ch2_out,
//output  [20:0]dead_time_out,

output reg[31:0]time_ch1_axi,
output reg[31:0]time_ch2_axi,
output reg[31:0]time_ch3_axi,
output reg[31:0]time_ch4_axi,
output reg[31:0]time_ch5_axi,
output reg[31:0]time_ch6_axi,
output reg[31:0]time_ch7_axi,
output reg[31:0]time_ch8_axi,





 
//input [20:0]time_window_input,
input reset_ext,
//input [20:0]dead_time_input,
output wire new_time
    );
    
reg [9:0]clk_counter;
reg [41:0]ns, ns_r;
reg [9:0] ns_clock;
reg [9:0]qs;
reg [9:0]ms;
reg [6:0]s;

reg [30:0]integration_time_r;

reg new_input_ch1;
reg new_input_ch2;
reg ch1_to_old;
reg ch2_to_old;


reg  reset_int;
reg [32:0]reset_timer;
wire reset = 0;
assign reset_out = reset;

reg [41:0] time_ch1_old;
reg [41:0] time_ch2_old;
reg [41:0] ns_ch1_old, ns_ch1_old2;
reg [41:0] ns_ch2_old, ns_ch2_old2;

reg [20:0]delay_ch1_r;
reg [20:0]delay_ch2_r;
reg [20:0]delay_ch3_r;
reg [20:0]delay_ch4_r;
reg [20:0]delay_ch5_r;
reg [20:0]delay_ch6_r;
reg [20:0]delay_ch7_r;
reg [20:0]delay_ch8_r;


reg ch1_clk1,ch1_clk2;
reg ch2_clk1,ch2_clk2;
reg ch3_clk1,ch3_clk2;
reg ch4_clk1,ch4_clk2;
reg ch5_clk1,ch5_clk2;
reg ch6_clk1,ch6_clk2;
reg ch7_clk1,ch7_clk2;
reg ch8_clk1,ch8_clk2;



reg ch1_overflow,ch2_overflow;
// monitoring 
//assign time_window_out = time_window_input;
//assign delay_ch1_out = delay_ch1_input;
//assign delay_ch2_out = delay_ch2_input;
//assign dead_time_out = dead_time_input;
//assign time_ch1_out = time_ch1[31:0];
//assign time_ch2_out = time_ch2[31:0];
//assign ScopeChannel3 = AFGchannel1; 

assign led_green = s[0];

wire overflow = ch1_overflow | ch2_overflow;

wire ch1_rise = ch1_clk1 & ~ch1_clk2;
wire ch2_rise = ch2_clk1 & ~ch2_clk2;
wire ch3_rise = ch3_clk1 & ~ch3_clk2;
wire ch4_rise = ch4_clk1 & ~ch4_clk2;
wire ch5_rise = ch5_clk1 & ~ch5_clk2;
wire ch6_rise = ch6_clk1 & ~ch6_clk2;
wire ch7_rise = ch7_clk1 & ~ch7_clk2;
wire ch8_rise = ch8_clk1 & ~ch8_clk2;
always @(posedge clk_250mhz)integration_time_r <= integration_time;
always @(posedge clk_250mhz) time_ch1_axi <= time_ch1[31:0];
always @(posedge clk_250mhz) time_ch2_axi <= time_ch2[31:0];
always @(posedge clk_250mhz) time_ch3_axi <= time_ch3[31:0];
always @(posedge clk_250mhz) time_ch4_axi <= time_ch4[31:0];
always @(posedge clk_250mhz) time_ch5_axi <= time_ch5[31:0];
always @(posedge clk_250mhz) time_ch6_axi <= time_ch6[31:0];
always @(posedge clk_250mhz) time_ch7_axi <= time_ch7[31:0];
always @(posedge clk_250mhz) time_ch8_axi <= time_ch8[31:0];



//clock *******************************************************
always @(posedge clk_250mhz) begin
    if (reset) begin
        //ns <= 0;
        qs <= 0;
        ms <= 0;
        s <= 0;
    end else begin
        ns <= ns + 4 ;
        ns_clock <= ns_clock + 4;
        if( ns_clock == 996) begin 
            ns_clock <= 0;
            qs <= qs + 1;
            if (qs == 999) begin 
                qs <= 0;
                ms <= ms + 1;
                if ( ms == 999) begin
                    s <= s + 1;
                    ms <= 0;
                end     
            end
        end
    end
end
always @(posedge clk_250mhz) begin
    if(reset)begin
        reset_int <= 0;
        reset_timer <= integration_time_r;
    end else if (reset_timer == 0)begin
        reset_int <= 1;
    end else
        reset_timer <= reset_timer - 4;
end        
// detect channel rise
always @(posedge clk_250mhz)begin
    ch1_clk1 <= ch1;
    ch2_clk1 <= ch2;
    ch3_clk1 <= ch3;
    ch4_clk1 <= ch4;
    ch5_clk1 <= ch5;
    ch6_clk1 <= ch6;
    ch7_clk1 <= ch7;
    ch8_clk1 <= ch8;
    ch1_clk2 <= ch1_clk1;
    ch2_clk2 <= ch2_clk1;
    ch3_clk2 <= ch3_clk1;
    ch4_clk2 <= ch4_clk1;
    ch5_clk2 <= ch5_clk1;
    ch6_clk2 <= ch6_clk1;
    ch7_clk2 <= ch7_clk1;
    ch8_clk2 <= ch8_clk1;
end
always @(posedge clk_250mhz) ns_r <= ns;
//detect channels time ***************************************************
// detect click channel 1
always @(posedge clk_250mhz) begin 
    delay_ch1_r <= delay_ch1;
    if (ch1_rise) begin
        time_ch1 <= ns_r - delay_ch1_r;
        new_time_ch1 <= 1;
    end else
        new_time_ch1 <= 0;
end
always @(posedge clk_250mhz) begin 
    delay_ch2_r <= delay_ch2;
    if (ch2_rise) begin
        time_ch2 <= ns_r - delay_ch2_r;
        new_time_ch2 <= 1;
    end else
        new_time_ch2 <= 0;
end
always @(posedge clk_250mhz) begin 
    delay_ch3_r <= delay_ch3;
    if (ch3_rise) begin
        time_ch3 <= ns_r - delay_ch3_r;
        new_time_ch3 <= 1;
    end else
        new_time_ch3 <= 0;
end
always @(posedge clk_250mhz) begin 
    delay_ch4_r <= delay_ch4;
    if (ch4_rise) begin
        time_ch4 <= ns_r - delay_ch4_r;
        new_time_ch4 <= 1;
    end else
        new_time_ch4 <= 0;
end
// detect click channel 5
always @(posedge clk_250mhz) begin 
    delay_ch5_r <= delay_ch5;
    if (ch5_rise) begin
        time_ch5 <= ns_r - delay_ch5_r;
        new_time_ch5 <= 1;
    end else
        new_time_ch5 <= 0;
end
always @(posedge clk_250mhz) begin 
    delay_ch6_r <= delay_ch6;
    if (ch6_rise) begin
        time_ch6 <= ns_r - delay_ch6_r;
        new_time_ch6 <= 1;
    end else
        new_time_ch6 <= 0;
end
always @(posedge clk_250mhz) begin 
    delay_ch7_r <= delay_ch7;
    if (ch7_rise) begin
        time_ch7 <= ns_r - delay_ch7_r;
        new_time_ch7 <= 1;
    end else
        new_time_ch7 <= 0;
end
always @(posedge clk_250mhz) begin 
    delay_ch8_r <= delay_ch8;
    if (ch8_rise) begin
        time_ch8 <= ns_r - delay_ch8_r;
        new_time_ch8 <= 1;
    end else
        new_time_ch8 <= 0;
end

// count singel clicks

always @(posedge clk_250mhz) begin
    if (reset) begin
        count_ch1 <= 0;
    end else if(new_time_ch1)begin
       count_ch1 <= count_ch1 + 1;
    end
end
always @(posedge clk_250mhz) begin
    if (reset) begin
        count_ch2 <= 0;
    end else if(new_time_ch2)begin
       count_ch2 <= count_ch2 + 1;
    end
end
always @(posedge clk_250mhz) begin
    if (reset) begin
        count_ch3 <= 0;
    end else if(new_time_ch3)begin
       count_ch3 <= count_ch3 + 1;
    end
end
always @(posedge clk_250mhz) begin
    if (reset) begin
        count_ch4 <= 0;
    end else if(new_time_ch4)begin
       count_ch4 <= count_ch4 + 1;
    end
end
always @(posedge clk_250mhz) begin
    if (reset) begin
        count_ch5 <= 0;
    end else if(new_time_ch5)begin
       count_ch5 <= count_ch5 + 1;
    end
end
always @(posedge clk_250mhz) begin
    if (reset) begin
        count_ch6 <= 0;
    end else if(new_time_ch6)begin
       count_ch6 <= count_ch6 + 1;
    end
end
always @(posedge clk_250mhz) begin
    if (reset) begin
        count_ch7 <= 0;
    end else if(new_time_ch7)begin
       count_ch7 <= count_ch7 + 1;
    end
end
always @(posedge clk_250mhz) begin
    if (reset) begin
        count_ch8 <= 0;
    end else if(new_time_ch8)begin
       count_ch8 <= count_ch8 + 1;
    end
end

// dma write thinks


endmodule