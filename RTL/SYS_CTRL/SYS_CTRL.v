`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2024 05:11:21 PM
// Design Name: 
// Module Name: SYS_CTRL
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
module SYS_CTRL #(
    parameter DATA_WIDTH    = 8,
    parameter ADDR_WIDTH    = 4,
    parameter ALU_OUT_WIDTH = 2*DATA_WIDTH,
    parameter ALU_FUN_WIDTH = 4      
    ) (
    input  wire                             CLK,
    input  wire                             RST,
    input  wire     [ALU_OUT_WIDTH-1 : 0]   ALU_OUT,
    input  wire                             OUT_Valid,
    output wire                             EN,
    output wire     [3               : 0]   ALU_FUN,
    output wire                             CLK_EN,
    output wire     [3               : 0]   address,
    output wire                             RdEn,
    output wire                             WrEn,
    output wire     [DATA_WIDTH-1    : 0]   WrData,
    input  wire     [DATA_WIDTH-1    : 0]   RdData,
    input  wire                             RdData_Valid,
    input  wire     [DATA_WIDTH-1    : 0]   RX_P_DATA,
    input  wire                             RX_D_VLD,
    output wire     [DATA_WIDTH-1    : 0]   TX_P_DATA,
    output wire                             TX_D_VLD,
    input  wire                             busy,
    output wire                             clk_div_en
    );


    wire            [2               : 0]   cmd_code;
    wire                                    cmd_analyze_en;
    wire            [1               : 0]   block_dir;
    wire            [1               : 0]   addr_code;
    wire            [1               : 0]   send_ctrl_sig;
    wire            [DATA_WIDTH-1    : 0]   ALU_OUT_TO_SEND_U;



    CTRL_FSM FSM_U (
        .CLK(CLK),
        .RST(RST),
        .rx_data_vld(RX_D_VLD),
        .tx_busy(busy),
        .reg_rd_data_vld(RdData_Valid),
        .cmd_code(cmd_code),
        .alu_out_vld(OUT_Valid),
        .alu_en(EN),
        .gclk_en(CLK_EN),
        .cmd_analyze_en(cmd_analyze_en),
        .block_dir(block_dir),
        .addr_code(addr_code),
        .send_ctrl_sig(send_ctrl_sig),
        .reg_wr_en(WrEn),
        .reg_rd_en(RdEn),
        .clk_div_en(clk_div_en)
    );


    FRM_ANLZ #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .ALU_FUN_WIDTH(ALU_FUN_WIDTH)
                                        ) ANLZ_U (
        .CLK(CLK),
        .RST(RST),
        .rx_data_out(RX_P_DATA),
        .cmd_analyze_en(cmd_analyze_en),
        .block_dir(block_dir),
        .addr_code(addr_code),
        .cmd_code(cmd_code),
        .alu_fun(ALU_FUN),
        .reg_wr_data(WrData),
        .reg_addr(address)
    );


    DATA_SEND #(
        .DATA_WIDTH(DATA_WIDTH)
                                    ) SEND_U (
        .CLK(CLK),
        .RST(RST),
        .send_ctrl_sig(send_ctrl_sig),
        .alu_out(ALU_OUT_TO_SEND_U),
        .reg_rd_data(RdData),
        .tx_in(TX_P_DATA),
        .tx_data_vld(TX_D_VLD)
    );

    
    MUX2 #(
        .DATA_WIDTH(DATA_WIDTH)
                                ) MUX2_U (
        .CLK(CLK),
        .RST(RST),
        .sel(send_ctrl_sig[1]),
        .in0(ALU_OUT[DATA_WIDTH-1 : 0]),                //First word of alu_out
        .in1(ALU_OUT[2*DATA_WIDTH-1 : DATA_WIDTH]),     //Second word of alu_out
        .mux_out(ALU_OUT_TO_SEND_U)
    );
    




endmodule