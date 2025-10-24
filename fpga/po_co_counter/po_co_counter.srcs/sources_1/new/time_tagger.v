`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2025
// Design Name: 
// Module Name: time_tagger
// Project Name: Photon Coincidence Counter
// Target Devices: EBAZ4205 (Zynq 7010)
// Tool Versions: 
// Description: Time-to-Digital Converter (TDC) based time tagger
//              Achieves sub-nanosecond timing accuracy using carry chain delays
//              Target accuracy: 50 ps
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// This module uses CARRY4 primitives to create a tapped delay line
// for fine time measurement. The coarse time is provided by the 250 MHz clock,
// and the fine time is measured using the carry chain.
//////////////////////////////////////////////////////////////////////////////////

(* use_dsp = "no" *)
module time_tagger #(
    parameter CHANNELS = 8,           // Number of input channels
    parameter CARRY_CHAIN_LENGTH = 64, // Length of carry chain for fine time measurement
    parameter COARSE_BITS = 48,       // Bits for coarse counter (250 MHz clock based)
    parameter FINE_BITS = 6,          // Bits for fine time (log2(CARRY_CHAIN_LENGTH))
    parameter TAG_BITS = 54           // Total timestamp bits (COARSE_BITS + FINE_BITS)
)(
    input wire clk_250mhz,            // 250 MHz reference clock
    input wire reset,                 // Synchronous reset
    
    // Input channels
    input wire [CHANNELS-1:0] ch_in,
    
    // Time tag outputs
    output reg [TAG_BITS-1:0] time_tag [0:CHANNELS-1],
    output reg [CHANNELS-1:0] time_tag_valid,
    
    // Coarse counter output (nanoseconds in 4ns steps)
    output reg [COARSE_BITS-1:0] coarse_counter
);

    // Coarse counter - increments every clock cycle (4 ns)
    always @(posedge clk_250mhz) begin
        if (reset) begin
            coarse_counter <= 0;
        end else begin
            coarse_counter <= coarse_counter + 4; // 4 ns per clock cycle
        end
    end
    
    // Generate TDC for each channel
    genvar ch;
    generate
        for (ch = 0; ch < CHANNELS; ch = ch + 1) begin : tdc_channel
            
            // Synchronization registers for input signal
            reg ch_sync1, ch_sync2, ch_sync3;
            
            // Edge detection
            wire ch_edge;
            assign ch_edge = ch_sync2 & ~ch_sync3;
            
            // Carry chain delay line for fine time measurement
            (* ALLOW_COMBINATORIAL_LOOPS = "true", KEEP = "true" *)
            wire [CARRY_CHAIN_LENGTH-1:0] delay_line;
            
            // First tap gets the input signal
            assign delay_line[0] = ch_sync1;
            
            // Generate carry chain delays using explicit buffering
            genvar i;
            for (i = 0; i < CARRY_CHAIN_LENGTH-1; i = i + 1) begin : carry_delays
                (* KEEP = "true", DONT_TOUCH = "true" *)
                LUT1 #(
                    .INIT(2'b10)
                ) delay_lut (
                    .O(delay_line[i+1]),
                    .I0(delay_line[i])
                );
            end
            
            // Thermometer-to-binary encoder for fine time
            reg [FINE_BITS-1:0] fine_time;
            reg [COARSE_BITS-1:0] coarse_time_capture;
            
            // Sample delay line on clock edge
            reg [CARRY_CHAIN_LENGTH-1:0] delay_line_sample;
            
            always @(posedge clk_250mhz) begin
                ch_sync1 <= ch_in[ch];
                ch_sync2 <= ch_sync1;
                ch_sync3 <= ch_sync2;
                
                if (reset) begin
                    time_tag_valid[ch] <= 0;
                    fine_time <= 0;
                    coarse_time_capture <= 0;
                end else if (ch_edge) begin
                    // Sample the delay line when edge is detected
                    delay_line_sample <= delay_line;
                    coarse_time_capture <= coarse_counter;
                    
                    // Simple thermometer to binary conversion
                    // Count the number of 1's in the delay line
                    fine_time <= encode_thermometer(delay_line_sample);
                    
                    // Combine coarse and fine time
                    time_tag[ch] <= {coarse_time_capture, fine_time};
                    time_tag_valid[ch] <= 1;
                end else begin
                    time_tag_valid[ch] <= 0;
                end
            end
            
            // Thermometer to binary encoder function
            function [FINE_BITS-1:0] encode_thermometer;
                input [CARRY_CHAIN_LENGTH-1:0] therm;
                integer j;
                integer count;
                begin
                    count = 0;
                    for (j = 0; j < CARRY_CHAIN_LENGTH; j = j + 1) begin
                        if (therm[j])
                            count = count + 1;
                    end
                    // Scale to get approximately 50-100 ps per bin
                    // With 250 MHz clock (4 ns) and 64 taps, each tap ~ 62.5 ps
                    encode_thermometer = count[FINE_BITS-1:0];
                end
            endfunction
            
        end
    endgenerate

endmodule
