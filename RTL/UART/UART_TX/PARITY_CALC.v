`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2024 09:56:27 PM
// Design Name: 
// Module Name: PARITY_CALC (UART-TX)
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
module PARITY_CALC #(
    parameter DATA_WIDTH = 8 
    ) (
    input   wire                        CLK,
    input   wire                        RST,
    input   wire  [DATA_WIDTH-1 : 0]    P_DATA,
    input   wire                        PAR_EN,
    input   wire                        PAR_TYP,
    output  reg                         PAR_BIT
    );

    reg                                 XOR_DATA;
    

    always @(posedge CLK, negedge RST)
    begin
        if (~RST) begin
            PAR_BIT  <= 1'b0;
            XOR_DATA <=  'b0;
        end
        else if(PAR_EN) begin
            XOR_DATA <= ^(P_DATA);
            case(PAR_TYP)
                1'b0: PAR_BIT <= XOR_DATA ? 1'b1 : 1'b0;   // even parity
                1'b1: PAR_BIT <= XOR_DATA ? 1'b0 : 1'b1;   // odd parity
            endcase
        end
        else
            PAR_BIT <= PAR_BIT;
    end
    
    
    
endmodule
