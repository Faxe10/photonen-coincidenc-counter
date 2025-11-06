`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2025 05:59:04 PM
// Design Name: 
// Module Name: tb_test
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


module tb_test(

    );
  logic clk = 0;
  always #5 clk = ~clk;
  logic [7:0]num1;
  logic [7:0]num2;
  logic [8:0]add_result;
  logic [8:0]sub_result;
  task automatic wait_clks(input int n); repeat(n) @(posedge clk); endtask
  test test_inst(
    .clk(clk),
    .num1(num1),
    .num2(num2),
    .add_result(add_result),
    .sub_result(sub_result)
    );
  initial begin 
    num1 = 2;
    num2 = 4;
    wait_clks(1);
    
  end
endmodule
