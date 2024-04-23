`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2024 06:00:56 PM
// Design Name: 
// Module Name: CLK_GATE
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
module CLK_GATE(
    input   wire    CLK,
    input   wire    CLK_EN,
    output  wire    GATED_CLK
    );
    
    reg             latched_en;
    

    always @(*) // Latch to avoid Pulse-Clipping and Spurious Clocking.
    begin
        if (~CLK) latched_en = CLK_EN;
    end

    
    assign GATED_CLK = CLK & latched_en;
    


endmodule
