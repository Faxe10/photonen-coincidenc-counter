`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2025 05:55:34 PM
// Design Name: 
// Module Name: test
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


module test(
 input clk,
 input logic [7:0] num1,
 input logic [7:0] num2,
 output logic [8:0] add_result,
 output logic [8:0] sub_result
    );
 always @(posedge clk)begin
    add_result <= num1+num2;
    sub_result <= num1-num2;
 end
endmodule
