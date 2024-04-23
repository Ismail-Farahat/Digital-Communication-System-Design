`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2024 09:48:28 PM
// Design Name: 
// Module Name: UART_TX
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
module UART_TX #(
    parameter DATA_WIDTH = 8 )(
    input   wire                            CLK,
    input   wire                            RST,
    input   wire                            PAR_EN,
    input   wire                            PAR_TYP,
    input   wire    [DATA_WIDTH-1 : 0]      P_DATA,
    input   wire                            DATA_VALID,
    output  wire                            S_DATA,
    output  wire                            busy
    );


    localparam                              start_bit = 1'b0;
    localparam                              stop_bit  = 1'b1;

    wire                                    t_ser_data;
    wire                                    t_ser_en;
    wire                                    t_ser_done;
    wire                                    t_par_bit;
    wire            [1            : 0]      t_mux_sel;
    


    SERIALIZER #(
        .DATA_WIDTH(DATA_WIDTH)
                                ) SER_U (
        .CLK(CLK),
        .RST(RST),
        .P_DATA(P_DATA),
        .ser_en(t_ser_en),
        .ser_data(t_ser_data),
        .ser_done(t_ser_done)
    );


    PARITY_CALC #(
        .DATA_WIDTH(DATA_WIDTH)
                                ) PAR_CAL_U (
        .CLK(CLK),
        .RST(RST),
        .P_DATA(P_DATA),
        .PAR_EN(PAR_EN),
        .PAR_TYP(PAR_TYP),
        .PAR_BIT(t_par_bit)
    );


    TX_FSM TX_FSM_U (
        .CLK(CLK),
        .RST(RST),
        .DATA_VALID(DATA_VALID),
        .PAR_EN(PAR_EN),
        .ser_done(t_ser_done),
        .mux_sel(t_mux_sel),
        .busy(busy),
        .ser_en(t_ser_en)
    );


    MUX4 MUX_U (
        .CLK(CLK),
        .RST(RST),
        .in0(start_bit),
        .in1(stop_bit),
        .in2(t_ser_data),
        .in3(t_par_bit),
        .sel(t_mux_sel),
        .mux_out(S_DATA)
    );



endmodule
