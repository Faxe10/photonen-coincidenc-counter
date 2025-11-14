
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
    output logic [`WIDTH_TIME_TAG:0] oTime_Tag,
 
    // debug ports;
    input logic [$clog2(`NUM_TAPPS)-1:0] iRead_tapp_addr,
    input logic iRead_delay,
    output logic [$clog2(`MAX_FINE_VAL)-1:0] oRd_delay
);
    logic new_hit_r;
    logic new_hit_r2;
    logic [$clog2(`WIDTH_NS)-1:0] ns_r;
    logic ns_to_ps;
    
    (* ram_style = "block" *) logic [$clog2(`MAX_FINE_VAL)-1:0] mem[`NUM_TAPPS];
    //def BRAM
     (*  dont_touch = "True" *)logic [$clog2(`MAX_FINE_VAL)-1:0]fine_val;
     (* dont_touch = "True" *) reg [$clog2(`NUM_TAPPS)-1:0]mem_read_addr;
     (* dont_touch = "True" *)logic [$clog2(`MAX_FINE_VAL)-1:0] read_data;
     (* dont_touch = "True" *)logic [$clog2(`MAX_FINE_VAL)-1:0] write_data;
     (* dont_touch = "True" *)logic [$clog2(`NUM_TAPPS)-1:0]    write_addr;
     assign oRd_delay = read_data;
     assign oTimeTag = 5;
    
    //5 clk = 18ns
    
    always @(posedge iCLK)begin
        if (iNew_val)begin
            fine_val <=  iTapp_val;
        end
    end
    always @(posedge iCLK)begin
        new_hit_r <= iNew_val;
        new_hit_r2 <= new_hit_r;
        ns_r <= iNS;
        ns_to_ps <= ns_r-18 << 4;
        if(new_hit_r2)begin
            oTime_Tag <= ns_to_ps - fine_val;
        end
    end          
   // logic for writing / reading BRAM     
    always @(posedge iCLK)begin 
        if (iNew_val)begin
            mem_read_addr <= iTapp_val;
        end
        else if (iRead_delay)begin
            mem_read_addr <= iRead_tapp_addr;
        end
    end 
    always @(posedge iCLK)begin
        if(iWrite_new_delay)begin
            write_data <= iTapp_delay;
            write_addr <= iWrite_tapp_addr;
        end;
    end       
    // BRAM read and write
    always @(posedge iCLK)begin
        mem[write_addr] <= write_data;
    end 
    always @(posedge iCLK)begin
        read_data <= mem[mem_read_addr];
    end  
endmodule       
 