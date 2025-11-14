`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2025 11:02:00 PM
// Design Name: 
// Module Name: hits_per_tapp
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
module hits_per_tapp(
    //default Signals
    input logic iCLK,
    input logic iRST,
    // signals for new Val
    input logic iNew_hit,
    input logic [ $clog2(`NUM_TAPPS)-1:0]iTapped_value,
    // signals for Cal read;
    input logic iStop_Counting,
    input logic iRead_Tapp,
    input logic [ $clog2(`NUM_TAPPS)-1:0]iRead_Tapp_Addr,
    output logic [`WIDTH_HISTOGRAM-1:0] oRd_data,
    output logic [32:0] oTotal
    );    
    wire reset;
    assign reset = iRST;
// mem def
    (* ram_style = "block" *)logic [`WIDTH_HISTOGRAM-1:0] mem_hits [0:`NUM_TAPPS-1];
    
    // mem controll read
    reg [$clog2(`NUM_TAPPS)-1:0]mem_read_addr,mem_read_addr_r;
    reg [$clog2(`NUM_TAPPS)-1:0] mem_write_addr;
    (* dont_touch = "True" *)logic [`WIDTH_HISTOGRAM-1:0] read_data;
    assign oRd_data = read_data;
    // mem controll write  
    reg [`WIDTH_HISTOGRAM-1:0]mem_write_data;
    // mem reset
    reg  [$clog2(`NUM_TAPPS)-1:0] clear_index;
    reg clearing;
//counting def
    reg [32:0]total;
    (* dont_touch = "True" *) reg new_hit_r,new_hit_r2;
    assign  oTotal = total;

    // total counting and BRAM clearing 
always @(posedge iCLK)begin
    new_hit_r2 <= new_hit_r;
    if (reset)begin
        clearing <= 1'b1;
        clear_index <= 1'b0;
    end 
    // clear mem Data
    else begin 
        if (clearing)begin
            clear_index <= clear_index +1;
            if(clear_index ==`NUM_TAPPS -1)begin
                clearing <= 1'b0;
                total <= 0;
            end
        end
        // write new val in mem
        else if (~iStop_Counting & new_hit_r2 ) begin 
            total <= total +1;
        end
    end
end
// logic for writing / reading BRAM     
    always @(posedge iCLK)begin
        new_hit_r <= iNew_hit;
        if (iRead_Tapp) begin 
            mem_read_addr <= iRead_Tapp_Addr;
        end 
        else begin 
            mem_read_addr <= iTapped_value;
        end

    end 

    always @(posedge iCLK)begin 
        mem_read_addr_r <= mem_read_addr;
        if(clearing)begin
            mem_write_data <= 0;
            mem_write_addr <= clear_index;
        end
        else if (~iStop_Counting & new_hit_r2) begin
            mem_write_data <= read_data + 1;
            mem_write_addr <= mem_read_addr_r;
        end
    end

// write and read counts in / from BRAM
always @(posedge iCLK)begin
    mem_hits[mem_write_addr] <= mem_write_data;
end
always @(posedge iCLK)begin 
    read_data <= mem_hits[mem_read_addr];
end






endmodule
