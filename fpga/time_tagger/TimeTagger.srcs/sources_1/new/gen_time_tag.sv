
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
///////////////////////////////////////////////// /////////////////////////////////
`include "settings.vh"
module gen_time_tag(
    input logic iCLK,
    // com cal tapp delay
    input logic iWrite_new_delay,
    input logic [$clog2(`MAX_FINE_VAL)-1:0] iTapp_delay,
    input logic [$clog2(`NUM_TAPPS)-1:0]    iWrite_tapp_addr,
    input logic iDelay_ready,
    // gen  time Tag
    input logic [$clog2(`WIDTH_NS)-1:0]iNS,
    input logic iNew_val,
    input logic [$clog2(`NUM_TAPPS)-1:0] iTapp_val,
    output logic [`WIDTH_TIME_TAG:0] oTime_Tag
 
    // debug ports;
  
);
    logic new_hit_r;
    logic ns_to_ps;
    logic [$clog2(`MAX_FINE_VAL)-1:0]fine_val;
    (* ram_style = "block" *) logic [$clog2(`MAX_FINE_VAL)-1:0] mem[`NUM_TAPPS];
    assign oTimeTag = 5;
    always @(posedge iCLK)begin
        if (iWrite_new_delay)begin
            mem[iWrite_tapp_addr] <= iTapp_delay;
        end 
    end
    //5 clk = 18ns
    
    always @(posedge iCLK)begin
        if (iNew_val)begin
            fine_val <= mem[iTapp_val];
        end
    end
    always @(posedge iCLK)begin
        new_hit_r <= iNew_val;
        ns_to_ps <= iNS-18 << 4;
        if(new_hit_r)begin
            oTime_Tag <= ns_to_ps - fine_val;
        end
    end            
endmodule       
 