`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2025 11:02:00 PM
// Design Name: 
// Module Name: historgamm
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
module histogramm(
    input logic iCLK,
    input logic iNew_hit,
    input logic iRead_mem,
    input logic iRst,
    input logic [ $clog2(`NUM_TAPPS-1):0]iTapped_value,
    input logic [ $clog2(`NUM_TAPPS-1):0]iRd_addr,
    output logic [`WIDHT_HISTOGRAM-1:0] oRd_data,
    //output logic [`WIDHT_HISTOGRAM-1:0] oRd_data_test,
    output logic oRd_data_ready,
    output logic [32:0] oTotal
    );
    (* ram_style = "block" *)logic [`WIDHT_HISTOGRAM-1:0] cnt_mem [0:`NUM_TAPPS-1];
    reg  [`WIDHT_HISTOGRAM-1:0]cnt_r;
    reg [32:0]total;
    reg clearing;
    reg cnt_mem_write;
    reg cnt_mem_read;
    reg [$clog2(`NUM_TAPPS)-1:0]cnt_mem_read_add;
    reg [$clog2(`NUM_TAPPS)-1:0]cnt_mem_write_add;
    reg [`WIDHT_HISTOGRAM-1:0]cnt_mem_write_data;
    reg [`WIDHT_HISTOGRAM-1:0]cnt_mem_read_data,cnt_mem_read_data_r;
    reg  [$clog2(`NUM_TAPPS)-1:0] clear_index;
    logic read_mem_sync,read_mem_old, read_mem_later;
    logic read_mem_rise;
    reg [ $clog2(`NUM_TAPPS)-1:0]tapped_delay_value_r;
    reg [ $clog2(`NUM_TAPPS)-1:0]tapped_delay_value_r2;
    reg [ $clog2(`NUM_TAPPS)-1:0]tapped_delay_value_r3;
    reg [ $clog2(`NUM_TAPPS)-1:0]tapped_delay_value_r4;
    (* dont_touch = "True" *) reg new_hit_r,new_hit_r2,new_hit_r3,new_hit_r4;
    logic [ $clog2(`NUM_TAPPS)-1:0] iRd_addr_r;
    always @(posedge iCLK) iRd_addr_r <= iRd_addr;
    always @(posedge iCLK) oTotal <= total;
    assign read_mem_rise = read_mem_sync & ~read_mem_old;
    always @(posedge iCLK) tapped_delay_value_r <=  iTapped_value;
    always @(posedge iCLK) begin
        tapped_delay_value_r2 <= tapped_delay_value_r;
        tapped_delay_value_r3 <= tapped_delay_value_r2;
        tapped_delay_value_r4 <= tapped_delay_value_r3;
    end
    always @(posedge iCLK) cnt_mem_read_data_r <= cnt_mem_read_data;
    always @(posedge iCLK) begin
        new_hit_r <= iNew_hit;
        new_hit_r2 <= new_hit_r;
        new_hit_r3 <= new_hit_r2;
        new_hit_r4 <= new_hit_r3;
    end
    always @(posedge iCLK) begin
        read_mem_sync <= iRead_mem;
        read_mem_old <= read_mem_sync;
    end
    always @(posedge iCLK)begin
        if (iRst) begin
            clearing <= 1'b1;
            clear_index <= 1'b0;
            total <= 32'd0 ;
        end
        else if(clearing)begin
            cnt_mem_write_data <= 0;
            cnt_mem_write <= 1'b1;
            cnt_mem_write_add <= clear_index;
            clear_index <= clear_index + 1;
            if (clear_index >`NUM_TAPPS -1)
                clearing <= 1'b0;
        end
        else begin
            if (new_hit_r)begin 
                cnt_mem_read <= 1'b1;
                cnt_mem_read_add <= tapped_delay_value_r;
            end
            else 
                cnt_mem_read <= 1'b0;
            if (new_hit_r4)begin
                cnt_mem_write_data <= cnt_mem_read_data_r + 1;
                cnt_mem_write_add <= tapped_delay_value_r4;
                cnt_mem_write <= 1'b1;
                total <= total +1;
            end 
            else
                cnt_mem_write <= 1'b0;
        end 
    end
    
always @(posedge iCLK)begin
    if (cnt_mem_write)begin
        cnt_mem[cnt_mem_write_add] <= cnt_mem_write_data;
    end 
end
always @(posedge iCLK)begin
    if(cnt_mem_read)begin
        cnt_mem_read_data <= cnt_mem[cnt_mem_read_add];
        oRd_data_ready <= 1'b0;
        if (read_mem_rise)begin
            read_mem_later <= 1'b1;
        end
    end 
    else if (read_mem_rise)begin
        oRd_data <= cnt_mem[iRd_addr_r];
        read_mem_later <= 1'b0;
        oRd_data_ready <= 1'b1;
    end else if (read_mem_later)begin
        oRd_data <= cnt_mem[iRd_addr_r];
        read_mem_later <= 1'b0;
        oRd_data_ready <= 1'b1;
    end
    else 
        oRd_data_ready <= 1'b0;

end    

endmodule
