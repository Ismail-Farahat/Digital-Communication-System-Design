`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2024 03:58:25 AM
// Design Name: 
// Module Name: PARITY_CHECK (UART-RX)
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
module PARITY_CHECK #(
    parameter DATA_WIDTH = 8           
    ) (
    input   wire                            CLK,
    input   wire                            RST,
    input   wire    [DATA_WIDTH-1 : 0]      P_DATA,
    input   wire                            sampled_bit,
    input   wire                            par_chk_en,
    input   wire                            PAR_TYP,
    output  reg                             par_err
    );

    wire                                    xor_data;


    assign xor_data = ^P_DATA;


    always @(posedge CLK, negedge RST)
    begin
        if(~RST) begin
            par_err <= 1'b0;
        end
        else if(par_chk_en) begin
            case(PAR_TYP)
                1'b0: par_err <= xor_data ^ sampled_bit;
                1'b1: par_err <= ~xor_data ^ sampled_bit;
            endcase
        end
        else
            par_err <= par_err;
    end



endmodule