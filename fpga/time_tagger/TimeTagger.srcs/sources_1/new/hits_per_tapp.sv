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
    (* ram_style = "block" *)logic [`WIDTH_HISTOGRAM-1:0] mem [0:`NUM_TAPPS-1];
    
    // mem controll read
    reg mem_read;
    reg [$clog2(`NUM_TAPPS)-1:0]mem_read_add,mem_read_add_r;
    reg [`WIDTH_HISTOGRAM-1:0]mem_read_data,mem_read_data_r;
    logic [`WIDTH_HISTOGRAM-1:0] read_data;
    assign oRd_data = read_data;
    // mem controll write  
    reg mem_write;
    reg [$clog2(`NUM_TAPPS)-1:0]mem_write_add;
    reg [`WIDTH_HISTOGRAM-1:0]mem_write_data;
    // mem reset
    reg  [$clog2(`NUM_TAPPS)-1:0] clear_index;
    reg clearing;
//counting def
    reg [32:0]total;
    reg [ $clog2(`NUM_TAPPS)-1:0]tapped_delay_value_r;
    (* dont_touch = "True" *) reg new_hit_r,new_hit_r2,new_hit_r3,new_hit_r4;
    assign  oTotal = total;



    always @(posedge iCLK) mem_read_data_r <= mem_read_data;

    
// logic for Counting the     
    always @(posedge iCLK)begin
        if (reset)begin
            total <= 0;
        end
        new_hit_r <= iNew_hit;
        new_hit_r2 <= new_hit_r;
        new_hit_r3 <= new_hit_r2;
        tapped_delay_value_r <=  iTapped_value;
        mem_read_add_r <= mem_read_add;
        if (new_hit_r)begin 
            mem_read_add <= tapped_delay_value_r;
        end
        if (new_hit_r3)begin
            mem_write_data <= mem_read_data + 1;
            mem_write_add <= mem_read_add_r;
            total <= total +1;
        end 
    end 

// write and read counts in / from BRAM
always @(posedge iCLK)begin
    new_hit_r4 <= new_hit_r3;
    if (reset)begin
        clearing <= 1'b1;
        clear_index <= 1'b0;
    end 
    // clear mem Data
    else if (clearing)begin
        mem[clear_index] <= 0;
        clear_index <= clear_index +1;
        if(clear_index ==`NUM_TAPPS -1)begin
            clearing <= 1'b0;
        end
    end
    // write new val in mem
    else if (~iStop_Counting & new_hit_r4 ) begin 
        mem[mem_write_add] <= mem_write_data;
    end
end

always @(posedge iCLK)begin
    if (iRead_Tapp)begin
        read_data <= mem[iRead_Tapp_Addr];
    end
    else if(new_hit_r2)begin
        mem_read_data <= mem[mem_read_add];
    end 


end    

endmodule
