`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2024 03:59:23 AM
// Design Name: 
// Module Name: UART_RX (UART-RX)
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
module UART_RX #(
    parameter DATA_WIDTH     = 8,
    parameter PRESCALE_WIDTH = 5
    ) (
    input   wire                                CLK,
    input   wire                                RST,
    input   wire                                PAR_EN,
    input   wire                                PAR_TYP,
    input   wire                                S_DATA,
    input   wire    [PRESCALE_WIDTH-1 : 0]      PRESCALE,
    output  wire    [DATA_WIDTH-1     : 0]      P_DATA,
    output  wire                                DATA_VALID,
    output  wire                                PAR_ERR,
    output  wire                                STP_ERR
    );


    wire            [3                : 0]      bit_cnt;
    wire            [2                : 0]      edge_cnt;
    wire                                        strt_glitch;
    wire                                        sample_en;
    wire                                        cnt_en;
    wire                                        par_chk_en;
    wire                                        strt_chk_en;
    wire                                        stp_chk_en;
    wire                                        deser_en;
    wire                                        sampled_bit;


    RX_FSM FSM_U (
        .CLK(CLK),
        .RST(RST),
        .S_DATA(S_DATA),
        .PAR_EN(PAR_EN),
        .bit_cnt(bit_cnt),
        .edge_cnt(edge_cnt),
        .par_err(PAR_ERR),
        .stp_err(STP_ERR),
        .strt_glitch(strt_glitch),
        .sample_en(sample_en), 
        .cnt_en(cnt_en),
        .par_chk_en(par_chk_en),
        .stp_chk_en(stp_chk_en),
        .strt_chk_en(strt_chk_en),
        .deser_en(deser_en),
        .DATA_VALID(DATA_VALID)
    );


    EDGE_BIT_COUNTER CNT_U (
        .CLK(CLK),
        .RST(RST),
        .cnt_en(cnt_en),
        .bit_cnt(bit_cnt),
        .edge_cnt(edge_cnt)
    );


    DATA_SAMPLING #(
        .PRESCALE_WIDTH(PRESCALE_WIDTH)
                                        ) SAMPLE_U (
        .CLK(CLK),
        .RST(RST),
        .S_DATA(S_DATA),
        .edge_cnt(edge_cnt),
        .sample_en(sample_en),
        .prescale(PRESCALE),
        .sampled_bit(sampled_bit)
    );


    DESERIALIZER #(
        .DATA_WIDTH(DATA_WIDTH)
                                    ) DESER_U (
        .CLK(CLK),
        .RST(RST),
        .deser_en(deser_en),
        .edge_cnt(edge_cnt),
        .sampled_bit(sampled_bit),
        .P_DATA(P_DATA)
    );


    STRT_CHECK STRT_CHK_U (
        .CLK(CLK),
        .RST(RST),
        .sampled_bit(sampled_bit),
        .strt_chk_en(strt_chk_en),
        .strt_glitch(strt_glitch)
    );


    STOP_CHECK STP_CHK_U (
        .CLK(CLK),
        .RST(RST),
        .sampled_bit(sampled_bit),
        .stp_chk_en(stp_chk_en),
        .stp_err(STP_ERR)
    );


    PARITY_CHECK #(
        .DATA_WIDTH(DATA_WIDTH)
                                ) PAR_CHK_U (
        .CLK(CLK),
        .RST(RST),
        .P_DATA(P_DATA),
        .sampled_bit(sampled_bit),
        .par_chk_en(par_chk_en),
        .PAR_TYP(PAR_TYP),
        .par_err(PAR_ERR)
    );




endmodule
