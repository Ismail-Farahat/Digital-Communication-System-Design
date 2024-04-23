`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 04:21:52 PM
// Design Name: 
// Module Name: multipliers_tb
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
module multipliers_tb();


    localparam N = 8;

    reg                     CLK;
    reg                     RST;
    reg                     en;
    reg     [N-1    : 0]    A;
    reg     [N-1    : 0]    B;
    wire    [2*N-1  : 0]    out_res;
    

    signed_multiplier DUT (
        .CLK(CLK),
        .RST(RST),
        .en(en),
        .A(A),
        .B(B),
        .out_res(out_res)
    );


    // Simulation Time
    initial #400 $finish;
    

    // Clock
    initial begin
        CLK = 0;
        RST = 0;
        en  = 0;
        A   = 'b0;
        B   = 'b0;
        forever #8 CLK = ~CLK;
    end
    
    // Input Data
    initial begin
        #(3*8) RST = 1; en = 1;
        #16 A=1;     B=125;
        #32 A=0;     B=125;
        #32 A=0;     B=0;
        #32 A=1;     B=1;
        #32 A=10;    B=11;
        #32 A=-10;   B=11;
        #32 A=-10;   B=-11;
        #32 A=111;   B=113;
        #32 A=27;    B=121;
        #32 A=125;   B=125;
        #32 A=3;     B=7;

    end
endmodule
