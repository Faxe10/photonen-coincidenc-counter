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
// Additional Comments
//
//////////////////////////////////////////////////////////////////////////////////

`include "settings.vh"
module tapped_delay_mem (

// ports for fine time cal
input logic iCLK,
input logic [`Channel_num-1:0]iRead,
input logic [`Channel_num*$clog2(`NUM_TAPPS)-1:0] iRead_Tapp,
output logic [`Channel_num*$clog2(`MAX_FINE_VAL)-1:0] oTapp_Delay,

// ports for write new delay val
input logic [`Channel_num-1:0] iWrite,
//input logic [`Channel_num*$clog2(`NUM_TAPPS)-1:0] iWrite_Tapp,
input logic [$clog2(`NUM_TAPPS)-1:0] iWrite_TAPP,
input logic [$clog2(`MAX_FINE_VAL)-1:0] iDelay_write_val

);

// var declar for Read

logic [`Channel_num-1:0] read_r;
logic [`Channel_num-1:0] write_r;
logic [$clog2(`NUM_TAPPS)-1:0] read_tapp [`Channel_num];
logic [$clog2(`MAX_FINE_VAL)-1:0] tapped_delay [`Channel_num];
//var declar for write
logic [$clog2(`Channel_num)-1:0] write_channel_r;
logic [$clog2(`MAX_FINE_VAL)-1:0] delay_write_val_r;
//logic [$clog2(`NUM_TAPPS)-1:0] write_tapp[`Channel_num];
logic [$clog2(`NUM_TAPPS)-1:0] write_tapp;
logic [$clog2(`MAX_FINE_VAL)-1:0] write_delay_val;
logic [$clog2(`Channel_num):0]x;

always @(posedge iCLK)  read_r <= iRead;
always @(posedge iCLK)  write_r <= iWrite;
always @(posedge iCLK)  write_delay_val <= iDelay_write_val;
always @(posedge iCLK) write_tapp <= iWrite_Tapp,
for (genvar ch = 0; ch < `Channel_num; ch++) begin
    always @(posedge iCLK)read_tapp[ch]  <= iRead_Tapp[ch*$clog2(`NUM_TAPPS) +: $clog2(`NUM_TAPPS)];
    //always @(posedge iCLK)write_tapp[ch] <= iWrite_Tapp[ch*$clog2(`NUM_TAPPS) +: $clog2(`NUM_TAPPS)];
    always @(posedge iCLK)oTapp_Delay[ch*$clog2(`MAX_FINE_VAL) +: $clog2(`MAX_FINE_VAL)]    <= tapped_delay[ch];
end 

for (genvar ch = 0; ch < `Channel_num;ch++)begin
    (* ram_style = "block" *) logic [$clog2(`MAX_FINE_VAL)-1:0] mem[`NUM_TAPPS];
    always @(posedge iCLK) begin
        if (read_r[ch])begin
            tapped_delay[ch] <= mem[read_tapp[ch]];
        end
    end
    
    always @(posedge iCLK) begin
        if(write_r[ch])begin
            mem[write_tapp] <= write_delay_val;
        end
    end
end

endmodule