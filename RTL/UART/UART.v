`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2024 09:48:28 PM
// Design Name: 
// Module Name: UART
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
module UART #(
    parameter DATA_WIDTH     = 8,
    parameter PRESCALE_WIDTH = 5
    ) (
    input   wire                                TX_CLK,
    input   wire                                RX_CLK,
    input   wire                                RST,
    input   wire                                PAR_EN,
    input   wire                                PAR_TYP,
    input   wire    [PRESCALE_WIDTH-1 : 0]      PRESCALE,

    input   wire    [DATA_WIDTH-1     : 0]      TX_IN,
    input   wire                                TX_DATA_VLD,
    output  wire                                TX_OUT,
    output  wire                                TX_BUSY,

    input   wire                                RX_IN,
    output  wire    [DATA_WIDTH-1     : 0]      RX_OUT,
    output  wire                                RX_DATA_VLD,

    output  wire                                PAR_ERR,
    output  wire                                FRM_ERR         // stop error in RX
);



    UART_TX #(
        .DATA_WIDTH(DATA_WIDTH)
                                    ) UART_TX_U (
        .CLK(TX_CLK),
        .RST(RST),
        .PAR_EN(PAR_EN),
        .PAR_TYP(PAR_TYP),
        .P_DATA(TX_IN),
        .DATA_VALID(TX_DATA_VLD),
        .S_DATA(TX_OUT),
        .busy(TX_BUSY)
    );



    UART_RX #(
        .DATA_WIDTH(DATA_WIDTH),
        .PRESCALE_WIDTH(PRESCALE_WIDTH)
                                        ) UART_RX_U (
        .CLK(RX_CLK),
        .RST(RST),
        .PAR_EN(PAR_EN),
        .PAR_TYP(PAR_TYP),
        .S_DATA(RX_IN),
        .PRESCALE(PRESCALE),
        .P_DATA(RX_OUT),
        .DATA_VALID(RX_DATA_VLD),
        .PAR_ERR(PAR_ERR),
        .STP_ERR(FRM_ERR)
    );




endmodule
