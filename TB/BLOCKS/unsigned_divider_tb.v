`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2024 10:04:37 PM
// Design Name: 
// Module Name: division
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
module unsigned_divider_tb();

    localparam N = 8;  // Number of bits for both divisor & dividend
    
    
    reg clk;
    reg rst_n;
    reg [N-1:0] in1;
    reg [N-1:0] in2;
    reg start_div;
    wire [N-1:0] div_out;
    wire [N-1:0] remainder;
    
    
    unsigned_divider DUT (
        .clk(clk),             
        .rst_n(rst_n),         
        .in1(in1),      
        .in2(in2),      
        .start_div(start_div),       
        .div_out(div_out), 
        .remainder(remainder),
        .error(error) 
    );
    
    
    // Simulation Time
    initial #150 $finish;
    
    // Clock
    initial begin
        rst_n       = 0;
        clk         = 0;
        start_div   = 0;
        in1         = 0;
        in2         = 0;
        forever #5 clk = ~clk; 
    end
    
    initial
    begin
        #15 rst_n = 1;
        #10 start_div = 1; in1 = 5; in2 = 3;      // div_out = 1, Remainder = 2, error = 0
        #10 start_div = 1; in1 = 15; in2 = 14;    // div_out = 1, Remainder = 1, error = 0
        #10 start_div = 1; in1 = 12; in2 = 5;     // div_out = 2, Remainder = 2, error = 0
        #10 start_div = 1; in1 = 0; in2 = 0;      // div_out = 0, Remainder = 0, error = 1, out_ready = 0
        #10 start_div = 1; in1 = 11; in2 = 0;     // div_out = 0, Remainder = 0, error = 1, out_ready = 0
        #10 start_div = 1; in1 = 0; in2 = 11;     // div_out = 0, Remainder = 0, error = 0
        #10 start_div = 1; in1 = 15; in2 = 15;    // div_out = 1, Remainder = 0, error = 0
        #10 start_div = 1; in1 = 15; in2 = 11;    // div_out = 1, Remainder = 4, error = 0
        #10 start_div = 1; in1 = 15; in2 = 1;     // div_out = 15, Remainder = 0, error = 0
        #10 start_div = 1; in1 = 1; in2 = 1;      // div_out = 1, Remainder = 0, error = 0
    end

endmodule
