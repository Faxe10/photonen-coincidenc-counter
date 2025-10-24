`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2025
// Design Name: 
// Module Name: time_tag_fifo
// Project Name: Photon Coincidence Counter
// Target Devices: EBAZ4205 (Zynq 7010)
// Tool Versions: 
// Description: FIFO buffer for storing time tags from multiple channels
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// Stores time tags with channel information for readout by PS
//////////////////////////////////////////////////////////////////////////////////

module time_tag_fifo #(
    parameter CHANNELS = 8,
    parameter TAG_BITS = 54,
    parameter FIFO_DEPTH = 1024,
    parameter ADDR_BITS = 10,
    parameter CHANNEL_BITS = 3
)(
    input wire clk,
    input wire reset,
    
    // Write interface (from time tagger)
    input wire [TAG_BITS-1:0] time_tags [0:CHANNELS-1],
    input wire [CHANNELS-1:0] time_tag_valid,
    
    // Read interface (to AXI)
    input wire read_enable,
    output reg [TAG_BITS-1:0] read_time_tag,
    output reg [CHANNEL_BITS-1:0] read_channel,
    output reg read_valid,
    
    // Status
    output reg fifo_full,
    output reg fifo_empty,
    output reg [ADDR_BITS:0] fifo_count
);

    // FIFO memory
    reg [TAG_BITS+CHANNEL_BITS-1:0] fifo_mem [0:FIFO_DEPTH-1];
    reg [ADDR_BITS-1:0] write_ptr;
    reg [ADDR_BITS-1:0] read_ptr;
    
    // Priority encoder for multi-channel write
    reg [CHANNEL_BITS-1:0] write_channel;
    reg write_enable;
    
    // Find first valid channel (priority encoder)
    always @(*) begin
        write_enable = 0;
        write_channel = 0;
        
        // Priority: channel 0 has highest priority
        if (time_tag_valid[0]) begin
            write_enable = 1;
            write_channel = 0;
        end else if (time_tag_valid[1]) begin
            write_enable = 1;
            write_channel = 1;
        end else if (time_tag_valid[2]) begin
            write_enable = 1;
            write_channel = 2;
        end else if (time_tag_valid[3]) begin
            write_enable = 1;
            write_channel = 3;
        end else if (time_tag_valid[4]) begin
            write_enable = 1;
            write_channel = 4;
        end else if (time_tag_valid[5]) begin
            write_enable = 1;
            write_channel = 5;
        end else if (time_tag_valid[6]) begin
            write_enable = 1;
            write_channel = 6;
        end else if (time_tag_valid[7]) begin
            write_enable = 1;
            write_channel = 7;
        end
    end
    
    // FIFO write logic
    always @(posedge clk) begin
        if (reset) begin
            write_ptr <= 0;
        end else if (write_enable && !fifo_full) begin
            fifo_mem[write_ptr] <= {time_tags[write_channel], write_channel};
            write_ptr <= write_ptr + 1;
        end
    end
    
    // FIFO read logic
    always @(posedge clk) begin
        if (reset) begin
            read_ptr <= 0;
            read_valid <= 0;
        end else if (read_enable && !fifo_empty) begin
            read_time_tag <= fifo_mem[read_ptr][TAG_BITS+CHANNEL_BITS-1:CHANNEL_BITS];
            read_channel <= fifo_mem[read_ptr][CHANNEL_BITS-1:0];
            read_ptr <= read_ptr + 1;
            read_valid <= 1;
        end else begin
            read_valid <= 0;
        end
    end
    
    // FIFO status
    always @(posedge clk) begin
        if (reset) begin
            fifo_count <= 0;
            fifo_empty <= 1;
            fifo_full <= 0;
        end else begin
            // Calculate fill level
            if (write_ptr >= read_ptr) begin
                fifo_count <= write_ptr - read_ptr;
            end else begin
                fifo_count <= FIFO_DEPTH - (read_ptr - write_ptr);
            end
            
            // Update flags
            fifo_empty <= (write_ptr == read_ptr);
            fifo_full <= ((write_ptr + 1) == read_ptr);
        end
    end

endmodule
