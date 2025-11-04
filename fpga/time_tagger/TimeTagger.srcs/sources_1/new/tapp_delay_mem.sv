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
module tapped_delay_mem (

// ports for fine time cal
input logic iCLK,
input logic iRead[`Channel_num],
input logic [$clog2(`NUM_TAPPS)-1:0] iRead_Tapp [`Channel_num],
output logic [$clog2(`MAX_FINE_VAL)-1:0] oTapp_Delay [`Channel_num],

// ports for write new delay val
input logic [$clog2(`Channel_num)-1:0] iWrite_channel,
input logic [$clog2(`NUM_TAPPS)-1:0] iWrite_Tapp,
input logic [$clog2(`MAX_FINE_VAL)-1:0] iDelay_write_val,
input logic iWrite

);

// var declar for Read
logic [$clog2(`MAX_FINE_VAL)-1:0] mem[`Channel_num] [`NUM_TAPPS];
logic  read_r[`Channel_num];
logic [$clog2(`NUM_TAPPS)-1:0] read_tapp_r [`Channel_num];
logic [$clog2(`MAX_FINE_VAL)-1:0] tapped_delay [`Channel_num];

//var declar for write
logic [$clog2(`Channel_num)-1:0] write_channel_r;
logic [$clog2(`MAX_FINE_VAL)-1:0] delay_write_val_r;
logic [$clog2(`NUM_TAPPS)-1:0] write_tapp_r;
logic write_r;


always @(posedge iCLK) begin
    read_r[0] <= iRead[0];
    read_tapp_r[0] <= iRead_Tapp[0];
    if (read_r[0])begin
        tapped_delay[0] <= mem[0][[read_tapp_r[0]];
    end
end

always @(posedge iCLK) begin
    write_channel_r <= iWrite_channel;
    delay_write_val_r <= iDelay_write_val;
    write_tapp_r <= iWrite_Tapp;
    write_r <= iWrite;
    if (write_r) begin
        mem[write_channel_r][write_tapp_r] <= delay_write_val_r;
    end
end
endmodule