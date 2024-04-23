`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2024 03:58:04 AM
// Design Name: 
// Module Name: DESERIALIZER (UART-RX)
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
/////////////////////////////////////////////////////////////////////////////////
module DESERIALIZER #(
    parameter DATA_WIDTH     = 8,
    parameter EDGE_CNT_WIDTH = 3
    ) (
    input   wire                          CLK,
    input   wire                          RST,
    input   wire                          deser_en,
    input   wire  [EDGE_CNT_WIDTH-1 : 0]  edge_cnt,
    input   wire                          sampled_bit,
    output  reg   [DATA_WIDTH-1     : 0]  P_DATA
    );


    always @(posedge CLK, negedge RST)
    begin
        if(~RST)
            P_DATA = 'b0;
        else if(deser_en) begin
            if (edge_cnt == {EDGE_CNT_WIDTH{1'b1}}) begin
                //P_DATA <= P_DATA<<1; P_DATA[0] <= sampled_bit;
                P_DATA               <= P_DATA>>1;
                P_DATA[DATA_WIDTH-1] <= sampled_bit;
            end
            else begin
                P_DATA = P_DATA;
            end
        end
        else
            P_DATA = P_DATA;
    end



endmodule
