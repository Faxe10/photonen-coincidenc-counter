
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2025 08:38:05 PM
// Design Name: 
// Module Name: tdc_top
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

module tdc_top(
    input iCLK,
    input wire iCH_1,
    input wire iRST,
    output wire [`WIDTH_TIME_TAG-1:0]oTime_Tag_ch1,
    output wire oReady_Led,

    // debug ports;
    input wire [$clog2(`NUM_TAPPS)-1:0] iRead_tapp_addr,
    input wire iRead_delay,
    output wire [$clog2(`COUNTS_FOR_CAL)-1:0]  oCal_counts,
    output wire [$clog2(`MAX_FINE_VAL)-1:0] oRd_delay,
    output wire  [$clog2(`COUNTS_FOR_CAL)-1:0] oCounts_per_s,
    output wire oNew_hit
    );
    reg [`WIDTH_NS:0] ns;
    reg [$clog2(`COUNTS_FOR_CAL)-1:0] counts_per_s;
    reg [$clog2(`COUNTS_FOR_CAL)-1:0] counts_last_s;
    reg [$clog2(299999999)-1:0]counter_clk;
    assign oCounts_per_s = counts_per_s; 
    always @(posedge iCLK)begin
      if (counter_clk ==299999999 )begin
            counter_clk <= 0;
            counts_per_s <= counts_last_s;
            counts_last_s <= 0;
        end 
        else begin 
            counter_clk <= counter_clk + 1 ;
            if (oNew_hit)begin
                counts_last_s <= counts_last_s + 1;
            end       
        end
    end
    wire reset;
    assign reste = iRST;
    always @(posedge iCLK)begin
        if (reset)begin
            ns <= 0;
        end
        else begin
            ns <=ns + 4;
        end
    end
    channel_controller channel_controller_ch1(
        .iCLK(iCLK),
        .iCH(iCH_1),
        .iRST(reset),
        .oCH_ready(oReady_Led),
        .iNS(ns),
        .oTime_Tag(oTime_Tag_ch1),
         // debug ports;
        .iRead_tapp_addr(iRead_tapp_addr),
        .iRead_delay(iRead_delay),
        .oRd_delay(oRd_delay),
        .oCal_counts(oCal_counts),
        .oNew_hit(oNew_hit)

    );
    
    //test inst_test(
    //    .hi(1'b1)
     //   );

endmodule
