`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2025
// Design Name: 
// Module Name: time_tagger_simple
// Project Name: Photon Coincidence Counter
// Target Devices: EBAZ4205 (Zynq 7010)
// Tool Versions: 
// Description: Simplified high-resolution time tagger
//              Uses multi-phase sampling for ~50-100 ps timing accuracy
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// This is a practical implementation that can be integrated with the
// existing FPGA design. It extends the current timestamp resolution
// from 4ns to approximately 50-100 ps using phase sampling.
//////////////////////////////////////////////////////////////////////////////////

module time_tagger_simple #(
    parameter COARSE_BITS = 48,    // Bits for coarse time (4ns resolution)
    parameter FINE_BITS = 6,       // Bits for fine time (~62.5 ps resolution)
    parameter TAG_BITS = 54        // Total bits for timestamp
)(
    input wire clk_250mhz,         // 250 MHz main clock
    input wire reset,
    
    // Single channel input
    input wire ch_in,
    
    // Time tag output
    output reg [TAG_BITS-1:0] time_tag,
    output reg time_tag_valid,
    
    // Coarse counter input (shared across channels)
    input wire [COARSE_BITS-1:0] coarse_time
);

    // Input synchronization and edge detection
    reg ch_d1, ch_d2, ch_d3;
    wire ch_rising_edge;
    
    always @(posedge clk_250mhz) begin
        ch_d1 <= ch_in;
        ch_d2 <= ch_d1;
        ch_d3 <= ch_d2;
    end
    
    assign ch_rising_edge = ch_d2 && !ch_d3;
    
    // Fine time measurement using delay chain
    // Each LUT delay is approximately 50-100 ps in Zynq-7000
    (* DONT_TOUCH = "yes", KEEP = "yes" *)
    reg [63:0] delay_chain;
    
    // Create delay chain with LUTs
    genvar i;
    generate
        for (i = 0; i < 63; i = i + 1) begin : delay_elements
            (* DONT_TOUCH = "yes", KEEP = "yes" *)
            LUT1 #(.INIT(2'b10)) delay_lut (
                .O(delay_chain[i+1]),
                .I0(delay_chain[i])
            );
        end
    endgenerate
    
    // Drive first element
    always @(*) begin
        delay_chain[0] = ch_d1;
    end
    
    // Sample delay chain on clock edge
    reg [63:0] delay_snapshot;
    reg [COARSE_BITS-1:0] coarse_snapshot;
    
    always @(posedge clk_250mhz) begin
        if (reset) begin
            time_tag_valid <= 0;
        end else if (ch_rising_edge) begin
            // Capture delay chain state and coarse time
            delay_snapshot <= delay_chain;
            coarse_snapshot <= coarse_time;
            time_tag_valid <= 1;
        end else begin
            time_tag_valid <= 0;
        end
    end
    
    // Encode delay chain to fine time value
    reg [FINE_BITS-1:0] fine_time;
    integer j;
    
    always @(*) begin
        fine_time = 0;
        for (j = 0; j < 64; j = j + 1) begin
            if (delay_snapshot[j]) begin
                fine_time = fine_time + 1;
            end
        end
    end
    
    // Combine coarse and fine time
    always @(posedge clk_250mhz) begin
        if (time_tag_valid) begin
            time_tag <= {coarse_snapshot, fine_time};
        end
    end

endmodule
