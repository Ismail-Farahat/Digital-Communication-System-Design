`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2024 06:07:57 PM
// Design Name: 
// Module Name: RegFile
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
module RegFile # (
    parameter REG_DEPTH  = 16,
    parameter DATA_WIDTH = 8,
    parameter REG_WIDTH  = 8                 
    ) ( 
    input   wire                                    CLK,
    input   wire                                    RST,
    input   wire    [$clog2(REG_DEPTH)-1 : 0]       address,
    input   wire                                    WrEn,
    input   wire                                    RdEn,
    input   wire    [DATA_WIDTH-1        : 0]       WrData,
    output  reg     [DATA_WIDTH-1        : 0]       RdData,
    output  reg                                     RdData_valid,
    output  wire    [REG_WIDTH-1         : 0]       REG0,
    output  wire    [REG_WIDTH-1         : 0]       REG1,
    output  wire    [REG_WIDTH-1         : 0]       REG2,
    output  wire    [REG_WIDTH-1         : 0]       REG3
    );


    reg             [DATA_WIDTH-1        : 0]       reg_data    [REG_DEPTH-1 : 0];

    integer                                         i;                // for loop



    always @(posedge CLK, negedge RST)
    begin
        if (~RST) begin
            RdData       <= 0;
            RdData_valid <= 0;
            for (i=0; i<REG_DEPTH; i = i+1) begin
                if      (i == 2)  reg_data[i]  <= 8'b0_01000_01;      //UART CONFIG
                else if (i == 3)  reg_data[i]  <= 8'b0000_1000;       //DIV RATIO
                else              reg_data[i]  <= {DATA_WIDTH{1'b0}}; //RESET the rest of reg
            end
        end
        else begin
            if (WrEn & ~RdEn) 
                reg_data[address] <= WrData;
            else if (RdEn & ~WrEn) begin
                RdData            <= reg_data[address];
                RdData_valid      <= 1'b1;
            end
            else
                RdData_valid      <= 1'b0;
        end
    end


    assign REG0 = reg_data [0];   //OPERAND A
    assign REG1 = reg_data [1];   //OPERAND B
    assign REG2 = reg_data [2];   //UART CONFIG
    assign REG3 = reg_data [3];   //DIV RATIO



endmodule
