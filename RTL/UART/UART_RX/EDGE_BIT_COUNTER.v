`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2024 03:59:12 AM
// Design Name: 
// Module Name: EDGE_BIT_COUNTER (UART-RX)
// Project Name: LowPowerMultiClockDigtialCommuSys
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
module EDGE_BIT_COUNTER #(
    parameter BIT_CNT_WIDTH  = 4,
    parameter EDGE_CNT_WIDTH = 3,
    parameter EDGE_CNT_STRT  = 3'b000,
    parameter EDGE_CNT_LMT   = 3'b111   
    ) (
    input   wire                         CLK,
    input   wire                         RST,
    input   wire                         cnt_en,
    output  reg  [BIT_CNT_WIDTH-1  : 0]  bit_cnt,
    output  reg  [EDGE_CNT_WIDTH-1 : 0]  edge_cnt
    );

    wire                                edge_cnt_done;


    always @(posedge CLK, negedge RST)
    begin
        if(~RST) begin
            edge_cnt <= EDGE_CNT_STRT;
            bit_cnt  <= 'b0;
        end
        else begin
            if(cnt_en) begin
                edge_cnt <= ~edge_cnt_done ? edge_cnt + 1 : EDGE_CNT_STRT;
                bit_cnt  <=  edge_cnt_done ? bit_cnt + 1  : bit_cnt;
            end
            else begin
                edge_cnt <= EDGE_CNT_STRT;
                bit_cnt  <=  'b0;
            end
        end
    end


    assign edge_cnt_done = (edge_cnt == EDGE_CNT_LMT);



endmodule
