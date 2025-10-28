`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2025 09:01:19 PM
// Design Name: 
// Module Name: tapped_delay_line
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

module tapped_delay_line(
    input iCLK,
    input iChannel,
    output logic oNew_hit,
    output reg [`NUM_TAPPS-1:0] oTAPPED_STATE
    );

wire [3:0] S  = 4'b1111;   // Propagate
wire [3:0] DI = 4;
wire [`NUM_TAPPS-1:0] tapped_state_w;
wire [`NUM_TAPPS-1:0] tapped_state_fdce_w_0;
wire [`NUM_TAPPS-1:0] tapped_state_fdce_w_1;

// Metastabilitie and edge detection
reg channel_sync;
reg channel_old;
reg channel_rise_r;
wire channel_rise;

always @(posedge iCLK) channel_sync <= iChannel;
always @(posedge iCLK) channel_old <= channel_sync;

always @(posedge iCLK) channel_rise_r <= channel_rise;
assign channel_rise = channel_sync & ~channel_old; 


always @(posedge iCLK)begin
    if (channel_rise_r)begin
        oTAPPED_STATE  <= tapped_state_fdce_w_1;
        oNew_hit <= 1;
    end else begin
        oNew_hit <= 0;
    end
end

genvar i;
generate 
    for(i=0; i <= `NUM_TAPPS/4-1; i = i+1)
        begin  
            if (i == 0)
             begin
             (*  dont_touch = "True" *) CARRY4 carry4_start(
                .CO(tapped_state_w[3:0]),
                .CI(1'b0),
                .DI(4'b0000),
                .CYINIT(iChannel),
                .S(4'b1111),
                .O()
                );
            end
            else 
            begin
                (*  dont_touch = "True" *) CARRY4 carry4_start(
                .CO(tapped_state_w[i*4+3:i*4]),
                .CI(tapped_state_w[4*i-1]),
                .CYINIT(1'b0),
                .DI(4'b0000),
                .S(4'b1111),
                .O()
                );
            end
        end
  endgenerate

genvar x;
generate 
    for (x=0; x <= `NUM_TAPPS -1 ;x = x+1)begin
        (* dont_touch = "True" *) FDCE fdceinst(
            .C(iCLK),
            .CE(iChannel),
            .D(tapped_state_w[x]),
            .Q(tapped_state_fdce_w_0[x])
            );
    end
endgenerate 

genvar y;
generate 
    for (y=0; y <= `NUM_TAPPS -1;y = y+1)begin
        (* dont_touch = "True" *) FDCE fdceinst(
            .C(iCLK),
            .CE(channel_rise),
            .D(tapped_state_fdce_w_0[y]),
            .Q(tapped_state_fdce_w_1[y])
            );
    end
endgenerate 


endmodule




