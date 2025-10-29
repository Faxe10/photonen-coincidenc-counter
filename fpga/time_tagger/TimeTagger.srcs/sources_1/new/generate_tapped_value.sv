`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2025 07:48:04 PM
// Design Name: 
// Module Name: generate_tapped_value
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
`include "settings.sv"

module generate_tapped_value(
 input wire [`NUM_TAPPS-1:0] tapped_state,
 input clk,
 input polarity
    );
    reg [9:0]thermometer_stop;
    reg [9:0]i;
    always @(posedge clk) begin
        for(i=0; i <= 149; i = i+1) begin
            if (tapped_state[i] == 1'b1 && (tapped_state[i+1] == 1'b0 && tapped_state[i+2] && tapped_state[i+3] == 1'b0)) 
            begin
                thermometer_stop <= i;
            end
        end
    end
endmodule
