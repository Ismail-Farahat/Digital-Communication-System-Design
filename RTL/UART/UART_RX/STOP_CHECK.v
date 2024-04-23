`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2024 03:58:55 AM
// Design Name: 
// Module Name: STOP_CHECK (UART-RX)
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
module STOP_CHECK(
    input   wire  CLK,
    input   wire  RST,
    input   wire  sampled_bit,
    input   wire  stp_chk_en,
    output  reg   stp_err
    );


    always @(posedge CLK, negedge RST)
    begin
        if(~RST)
            stp_err <= 1'b0;
        else if(stp_chk_en)
            stp_err <=  ~sampled_bit;  // stop bit MUST be ONE
        else
            stp_err <= stp_err;
    end


endmodule
