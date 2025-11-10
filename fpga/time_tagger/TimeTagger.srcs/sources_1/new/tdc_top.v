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
    input iCLK,
    input wire iCH_1,
    input wire iRST,
    output wire [`WIDTH_TIME_TAG-1:0]oTime_Tag_ch1

    );
    wire reset;
    wire ch_1;
    assign reste = iRST;
    assign ch_1 = iCH_1;
    
    channel_controller channel_controller_ch1(
        .iCLK(clk),
        .iCH(ch_1),
        .iRST(reset),
        .oTime_Tag(oTime_Tag_ch1)
    );

    //test inst_test(
    //    .hi(1'b1)
     //   );

endmodule
