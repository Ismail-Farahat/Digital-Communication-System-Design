`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2024 09:53:40 PM
// Design Name: 
// Module Name: ClkDiv_tb
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
module CLK_DIV_TB();
    
    localparam RATIO_WIDTH = 4;
    
    reg                       i_ref_clk;
    reg                       i_rst;  //active low
    reg                       i_clk_en; //active low
    reg  [RATIO_WIDTH-1 : 0]  i_div_ratio;
    wire                      o_div_clk;
    
    ClkDiv CD (
        .i_ref_clk(i_ref_clk),
        .i_rst(i_rst), 
        .i_clk_en(i_clk_en),
        .i_div_ratio(i_div_ratio),
        .o_div_clk(o_div_clk)
    );


    // Simulation Time
    initial
    begin  
        #600 $finish;
    end
    
    // Clock
    initial begin
        i_ref_clk = 0;
        i_rst = 0;
        i_clk_en = 0;
        forever begin
        #8 i_ref_clk = ~i_ref_clk;
        end
    end
    
    // Input Data
    initial begin
        #(3*8) i_rst = 1; i_div_ratio = 4'b0100;
        #(2*8) i_clk_en = 1;
        //#(8*8) i_clk_en = 0;
        //#(10*8) i_clk_en = 1; i_div_ratio = 4'b0010;
    end
endmodule
