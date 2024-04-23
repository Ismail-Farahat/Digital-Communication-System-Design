`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2024 05:22:15 AM
// Design Name: 
// Module Name: BIT_SYNC
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
module BIT_SYNC(
    input   wire    CLK,
    input   wire    RST,
    input   wire    un_sync_bit,
    output  wire    sync_bit
    );

    reg             sync1, 
                    sync2;


    always @(posedge CLK, negedge RST)
    begin
        if(~RST) begin
            sync1 <= 1'b0;
            sync2 <= 1'b0;
        end
        else begin
            sync1 <= un_sync_bit;
            sync2 <= sync1;
        end
    end


    assign sync_bit = sync2;



endmodule
