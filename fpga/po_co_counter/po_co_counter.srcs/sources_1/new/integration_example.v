`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Integration Example: Adding Time Tagger to Existing Design
//
// This file shows how to integrate the time_tagger_simple module
// into the existing start.v module to add high-resolution time tagging
// capability to the photon coincidence counter.
//
// Instructions:
// 1. Add time tagger instances for each channel
// 2. Connect to existing coarse time counter (ns signal)
// 3. Add AXI GPIO interfaces for reading time tags
// 4. Optionally add FIFO for buffering
//////////////////////////////////////////////////////////////////////////////////

// Example integration in start.v module
// Add these declarations after the existing outputs:

/*
// Time tagger outputs
output reg [53:0] time_tag_ch1,
output reg [53:0] time_tag_ch2,
output reg [53:0] time_tag_ch3,
output reg [53:0] time_tag_ch4,
output reg [53:0] time_tag_ch5,
output reg [53:0] time_tag_ch6,
output reg [53:0] time_tag_ch7,
output reg [53:0] time_tag_ch8,

output reg time_tag_valid_ch1,
output reg time_tag_valid_ch2,
output reg time_tag_valid_ch3,
output reg time_tag_valid_ch4,
output reg time_tag_valid_ch5,
output reg time_tag_valid_ch6,
output reg time_tag_valid_ch7,
output reg time_tag_valid_ch8
*/

// Add these wire declarations inside the module:

/*
wire [53:0] time_tag_ch1_internal;
wire [53:0] time_tag_ch2_internal;
wire [53:0] time_tag_ch3_internal;
wire [53:0] time_tag_ch4_internal;
wire [53:0] time_tag_ch5_internal;
wire [53:0] time_tag_ch6_internal;
wire [53:0] time_tag_ch7_internal;
wire [53:0] time_tag_ch8_internal;

wire time_tag_valid_ch1_internal;
wire time_tag_valid_ch2_internal;
wire time_tag_valid_ch3_internal;
wire time_tag_valid_ch4_internal;
wire time_tag_valid_ch5_internal;
wire time_tag_valid_ch6_internal;
wire time_tag_valid_ch7_internal;
wire time_tag_valid_ch8_internal;
*/

// Instantiate time taggers for each channel:

/*
// Channel 1 Time Tagger
time_tagger_simple #(
    .COARSE_BITS(48),
    .FINE_BITS(6),
    .TAG_BITS(54)
) tagger_ch1 (
    .clk_250mhz(clk_250mhz),
    .reset(reset),
    .ch_in(ch1),
    .time_tag(time_tag_ch1_internal),
    .time_tag_valid(time_tag_valid_ch1_internal),
    .coarse_time(ns[47:0])  // Use lower 48 bits of ns counter
);

// Channel 2 Time Tagger
time_tagger_simple #(
    .COARSE_BITS(48),
    .FINE_BITS(6),
    .TAG_BITS(54)
) tagger_ch2 (
    .clk_250mhz(clk_250mhz),
    .reset(reset),
    .ch_in(ch2),
    .time_tag(time_tag_ch2_internal),
    .time_tag_valid(time_tag_valid_ch2_internal),
    .coarse_time(ns[47:0])
);

// Repeat for channels 3-8...
// (Similar instantiations for ch3-ch8)

// Register outputs
always @(posedge clk_250mhz) begin
    time_tag_ch1 <= time_tag_ch1_internal;
    time_tag_ch2 <= time_tag_ch2_internal;
    time_tag_ch3 <= time_tag_ch3_internal;
    time_tag_ch4 <= time_tag_ch4_internal;
    time_tag_ch5 <= time_tag_ch5_internal;
    time_tag_ch6 <= time_tag_ch6_internal;
    time_tag_ch7 <= time_tag_ch7_internal;
    time_tag_ch8 <= time_tag_ch8_internal;
    
    time_tag_valid_ch1 <= time_tag_valid_ch1_internal;
    time_tag_valid_ch2 <= time_tag_valid_ch2_internal;
    time_tag_valid_ch3 <= time_tag_valid_ch3_internal;
    time_tag_valid_ch4 <= time_tag_valid_ch4_internal;
    time_tag_valid_ch5 <= time_tag_valid_ch5_internal;
    time_tag_valid_ch6 <= time_tag_valid_ch6_internal;
    time_tag_valid_ch7 <= time_tag_valid_ch7_internal;
    time_tag_valid_ch8 <= time_tag_valid_ch8_internal;
end
*/

// Optional: Add FIFO for buffering time tags

/*
// Collect all time tags into arrays
wire [53:0] all_time_tags [0:7];
wire [7:0] all_time_tag_valid;

assign all_time_tags[0] = time_tag_ch1_internal;
assign all_time_tags[1] = time_tag_ch2_internal;
assign all_time_tags[2] = time_tag_ch3_internal;
assign all_time_tags[3] = time_tag_ch4_internal;
assign all_time_tags[4] = time_tag_ch5_internal;
assign all_time_tags[5] = time_tag_ch6_internal;
assign all_time_tags[6] = time_tag_ch7_internal;
assign all_time_tags[7] = time_tag_ch8_internal;

assign all_time_tag_valid = {
    time_tag_valid_ch8_internal,
    time_tag_valid_ch7_internal,
    time_tag_valid_ch6_internal,
    time_tag_valid_ch5_internal,
    time_tag_valid_ch4_internal,
    time_tag_valid_ch3_internal,
    time_tag_valid_ch2_internal,
    time_tag_valid_ch1_internal
};

// Time tag FIFO instance
time_tag_fifo #(
    .CHANNELS(8),
    .TAG_BITS(54),
    .FIFO_DEPTH(1024),
    .ADDR_BITS(10),
    .CHANNEL_BITS(3)
) tag_buffer (
    .clk(clk_250mhz),
    .reset(reset),
    
    // Write interface (from time taggers)
    .time_tags(all_time_tags),
    .time_tag_valid(all_time_tag_valid),
    
    // Read interface (to AXI GPIO)
    .read_enable(fifo_read_enable),      // Connect to AXI GPIO
    .read_time_tag(fifo_read_data),      // Connect to AXI GPIO
    .read_channel(fifo_read_channel),    // Connect to AXI GPIO
    .read_valid(fifo_read_valid),        // Connect to AXI GPIO
    
    // Status
    .fifo_full(fifo_full),               // Connect to status register
    .fifo_empty(fifo_empty),             // Connect to status register
    .fifo_count(fifo_count)              // Connect to status register
);
*/

endmodule
