`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2024 03:58:41 AM
// Design Name: 
// Module Name: STRT_CHECK (UART-RX)
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
module STRT_CHECK(
    input   wire  CLK,
    input   wire  RST,
    input   wire  sampled_bit,
    input   wire  strt_chk_en,
    output  reg   strt_glitch
    );


    always @(posedge CLK, negedge RST)
    begin
        if(~RST)
            strt_glitch <= 1'b0;
        else if(strt_chk_en)
            strt_glitch <= (sampled_bit == 1'b1);
        else
            strt_glitch <= strt_glitch;
    end


endmodule
