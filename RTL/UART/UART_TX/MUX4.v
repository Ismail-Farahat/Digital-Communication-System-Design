`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2024 09:59:19 PM
// Design Name: 
// Module Name: MUX4 (UART-TX)
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
module MUX4(
    input   wire             CLK,
    input   wire             RST,
    input   wire             in0,
    input   wire             in1,
    input   wire             in2,
    input   wire             in3,
    input   wire   [1 : 0]   sel,
    output  reg              mux_out
    );


    always @(posedge CLK, negedge RST)
    begin
        if (~RST)
            mux_out <= 1'b1;
        else begin
            case(sel)
                2'b00: mux_out <= in0;
                2'b01: mux_out <= in1;
                2'b10: mux_out <= in2;
                2'b11: mux_out <= in3;
            endcase
        end
    end



endmodule
