`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 01:32:53 PM
// Design Name: 
// Module Name: MUX2 (SYS_CTRL)
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
module MUX2 #(
    parameter DATA_WIDTH = 8
    ) (
    input   wire                            CLK,
    input   wire                            RST,
    input   wire                            sel,
    input   wire    [DATA_WIDTH-1 : 0]      in0,
    input   wire    [DATA_WIDTH-1 : 0]      in1,
    output  reg     [DATA_WIDTH-1 : 0]      mux_out
    );


    always @(posedge CLK, negedge RST)
    begin
        if(~RST)
            mux_out <= 'b0;
        else begin
            case(sel)
                1'b0: mux_out <= in0;
                1'b1: mux_out <= in1;
            endcase
        end
    end



endmodule
