`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Light and Matter Group, Leibniz University Hannover
// Engineer: Fabian Walther fabian@cryptix.de
//
// Create Date: 11/7/2025 04:01:19 PM
// Design Name: Photonen Coincidence Counter
// Module Name: gen_time_tag
// Project Name: 2QA Entanglement demonstrator
// Target Devices: EBAZ4205
// Tool Versions:
// Description:
// generates the Time Tag
//  to Time Tag
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`include "settings.vh"
module gen_time_tag(
    input logic iCLK,
    input logic iWrite_new_delay,
    input logic [$clog2(`MAX_FINE_VAL)-1:0] iNew_tapp_delay,
    input logic [$clog2(`NUM_TAPPS)-1:0]    iWrite_tapp_add
)
    (* ram_style = "block" *) logic [$clog2(`MAX_FINE_VAL)-1:0] mem[`NUM_TAPPS];
    always @(posedge iCLK) begin
        if (read_delay) begin
            delay_to_tapp <= mem[read_tapp_addr];
        end
    end
    always @(posedge iCLK)begin
        if (iWrite_new_delay)begin
            mem[iWrite_tapp_add] <= iNew_tapp_delay;
        end
    end
endmodule