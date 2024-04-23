`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2024 10:39:28 PM
// Design Name: 
// Module Name: SYSTEM_TOP
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
module SYSTEM_TOP #(
    parameter DATA_WIDTH        = 8,
    parameter REG_DEPTH         = 16,
    parameter ADDR_WIDTH        = $clog2(REG_DEPTH),
    parameter ALU_FUN_WIDTH     = 4,
    parameter ALU_OUT_WIDTH     = 2*DATA_WIDTH,
    parameter PRESCALE_WIDTH    = 5,
    parameter DIV_RATIO_WIDTH   = 4 
    ) (
    input   wire                        REF_CLK,
    input   wire                        UART_CLK,
    input   wire                        RST,
    input   wire                        RX_IN,
    output  wire                        TX_OUT,
    output  wire                        PAR_ERR,
    output  wire                        FRM_ERR
);

    wire                                SYNC_RST_REF;
    wire                                SYNC_RST_UART;

    wire                                TX_CLK;
    wire                                clk_div_en;
    wire    [DIV_RATIO_WIDTH-1 : 0]     DIV_RATIO;

    wire                                GCLK;
    wire                                CLK_EN;
    wire    [ALU_FUN_WIDTH-1   : 0]     ALU_FUN;
    wire                                ALU_EN;
    wire    [ALU_OUT_WIDTH-1   : 0]     ALU_OUT;
    wire                                ALU_OUT_VLD;

    wire    [DATA_WIDTH-1      : 0]     UART_CONFIG;
    wire                                PAR_EN;
    wire                                PAR_TYP;
    wire    [PRESCALE_WIDTH    : 0]     PRESCALE;       // extra bit: to avoid un read bit (bit 7) from UART_CONFIG
    
    wire    [DATA_WIDTH-1      : 0]     operand1;
    wire    [DATA_WIDTH-1      : 0]     operand2;
    wire    [ADDR_WIDTH-1      : 0]     address;
    wire                                WrEN;
    wire                                RdEn;
    wire    [DATA_WIDTH-1      : 0]     WrData;
    wire    [DATA_WIDTH-1      : 0]     RdData;
    wire                                RdData_valid;

    wire    [DATA_WIDTH-1      : 0]     RX_P_DATA;
    wire                                RX_D_VLD;
    wire    [DATA_WIDTH-1      : 0]     TX_P_DATA;
    wire                                TX_D_VLD;
    wire                                TX_BUSY;

    wire    [DATA_WIDTH-1      : 0]     SYNC_RX_P_DATA;
    wire                                SYNC_RX_D_VLD;
    wire    [DATA_WIDTH-1      : 0]     SYNC_TX_P_DATA;
    wire                                SYNC_TX_D_VLD;
    wire                                SYNC_TX_BUSY;




    assign PAR_EN   = UART_CONFIG[0];
    assign PAR_TYP  = UART_CONFIG[1];
    assign PRESCALE = UART_CONFIG[7:2];


    //================================================================//
    //======================    DEBUG & OPTIMIZATION    ==============//
    //================================================================//
    /*
    integer     log_file;
    initial begin
        log_file = $fopen("./test.log", "w");
    end

    always @(   CTRL_U0.FSM_U.state, 
                RX_P_DATA, RX_D_VLD, SYNC_RX_P_DATA, SYNC_RX_D_VLD,
                address, 
                RdEn, RdData, RdData_valid, WrEN, WrData,
                ALU_EN, ALU_FUN, operand1, operand2, ALU_OUT, ALU_OUT_VLD,
                TX_P_DATA, TX_D_VLD, SYNC_TX_P_DATA, SYNC_TX_D_VLD,
                TX_BUSY, SYNC_TX_BUSY) 
    begin
        $fwrite(log_file,   "========================================================\n");
        $fwrite(log_file,   "@TIME = %d\n--> STATE= %h\nREF_CLK= %d,   UART_CLK= %d,   TX_CLK=%d\n",
                             $time, CTRL_U0.FSM_U.state, REF_CLK, UART_CLK, TX_CLK);
        $fwrite(log_file,   "RX-: D= %h, VLD= %b, SYNC_D= %h, SYNC_VLD= %b\n",
                            RX_P_DATA, RX_D_VLD, SYNC_RX_P_DATA, SYNC_RX_D_VLD);
        $fwrite(log_file,   "ADR: Address= %h\n",
                            address);
        $fwrite(log_file,   "RE-: RdEn= %h, D= %h, VLD= %b\n", 
                            RdEn, RdData, RdData_valid);
        $fwrite(log_file,   "Wr-: WrEn= %b, D= %h\n",
                            WrEN, WrData);
        $fwrite(log_file,   "ALU: ALU_En= %b, F= %h, OP1= %h, OP2= %h, R= %h, VLD= %b\n",
                            ALU_EN, ALU_FUN, operand1, operand2, ALU_OUT, ALU_OUT_VLD);
        $fwrite(log_file,   "TX-: D= %h, VLD= %b, SYNC_D= %h, SYNC_VLD= %b\n",
                            TX_P_DATA, TX_D_VLD, SYNC_TX_P_DATA, SYNC_TX_D_VLD);
        $fwrite(log_file,   "TX-: BUSY= %b, SYNC_BUSY= %b\n",
                            TX_BUSY, SYNC_TX_BUSY);
    end
    */
    //================================================================//
    //================================================================//
    //================================================================//




    //================================================================//
    //======================    REG FILE    ==========================//
    //================================================================//
    RegFile # (
        .REG_DEPTH(REG_DEPTH),
        .DATA_WIDTH(DATA_WIDTH),
        .REG_WIDTH(DATA_WIDTH)                
                                ) REG_U ( 
        .CLK(REF_CLK),
        .RST(SYNC_RST_REF),
        .address(address),
        .WrEn(WrEN),
        .RdEn(RdEn),
        .WrData(WrData),
        .RdData(RdData),
        .RdData_valid(RdData_valid),
        .REG0(operand1),
        .REG1(operand2),
        .REG2(UART_CONFIG),
        .REG3(DIV_RATIO)
    );



    //================================================================//
    //======================    CONTROL UNIT    ======================//
    //================================================================//

    SYS_CTRL #(
        .DATA_WIDTH(DATA_WIDTH),
        .ALU_OUT_WIDTH(ALU_OUT_WIDTH),
        .ALU_FUN_WIDTH(ALU_FUN_WIDTH)
                                        ) CTRL_U0 (
        .CLK(REF_CLK),
        .RST(SYNC_RST_REF),
        .ALU_OUT(ALU_OUT),
        .OUT_Valid(ALU_OUT_VLD),
        .EN(ALU_EN),
        .ALU_FUN(ALU_FUN),
        .CLK_EN(CLK_EN),
        .address(address),
        .RdEn(RdEn),
        .WrEn(WrEN),
        .WrData(WrData),
        .RdData(RdData),
        .RdData_Valid(RdData_valid),
        .RX_P_DATA(SYNC_RX_P_DATA),
        .RX_D_VLD(SYNC_RX_D_VLD),
        .TX_P_DATA(TX_P_DATA),
        .TX_D_VLD(TX_D_VLD),
        .busy(SYNC_TX_BUSY),
        .clk_div_en(clk_div_en)
    );


    //================================================================//
    //======================    CLOCK DIVIDER    =====================//
    //================================================================//
    ClkDiv #(
        .RATIO_WIDTH(DIV_RATIO_WIDTH)
                                        ) CLK_DIV_U0 (
        .i_ref_clk(UART_CLK),
        .i_rst(SYNC_RST_UART),
        .i_clk_en(clk_div_en),
        .i_div_ratio(DIV_RATIO),
        .o_div_clk(TX_CLK)
    );



    //================================================================//
    //======================    UART    ==============================//
    //================================================================//
    UART #(
        .DATA_WIDTH(DATA_WIDTH),
        .PRESCALE_WIDTH(PRESCALE_WIDTH)
                                        ) UART_U0 (
        .TX_CLK(TX_CLK),
        .RX_CLK(UART_CLK),
        .RST(SYNC_RST_UART),
        .PAR_EN(PAR_EN),
        .PAR_TYP(PAR_TYP),
        .PRESCALE(PRESCALE),
        .TX_IN(SYNC_TX_P_DATA),
        .TX_DATA_VLD(SYNC_TX_D_VLD),
        .TX_OUT(TX_OUT),
        .TX_BUSY(TX_BUSY),
        .RX_IN(RX_IN),
        .RX_OUT(RX_P_DATA),
        .RX_DATA_VLD(RX_D_VLD),
        .PAR_ERR(PAR_ERR),
        .FRM_ERR(FRM_ERR)
    );


    //================================================================//
    //======================    CLOCK GATING    ======================//
    //================================================================//
    CLK_GATE CLK_GATE_U0 (
        .CLK(REF_CLK),
        .CLK_EN(CLK_EN),
        .GATED_CLK(GCLK)
    );



    //================================================================//
    //======================    ALU    ===============================//
    //================================================================//
    ALU #(
        .DATA_WIDTH(DATA_WIDTH),
        .RESULT_WIDTH(ALU_OUT_WIDTH),
        .FUN_WIDTH(ALU_FUN_WIDTH)        
                                    ) ALU_U0 (
        .CLK(GCLK),
        .RST(SYNC_RST_REF),
        .A(operand1),
        .B(operand2),
        .ALU_FUN(ALU_FUN),
        .enable(ALU_EN),
        .ALU_OUT(ALU_OUT),
        .OUT_VALID(ALU_OUT_VLD)
    );



    //================================================================//
    //======================    BIT SYNCHRONIZER    ==================//
    //================================================================//
    BIT_SYNC BIT_SYNC_U0 (
        .CLK(UART_CLK),
        .RST(SYNC_RST_UART),
        .un_sync_bit(TX_BUSY),
        .sync_bit(SYNC_TX_BUSY)
    );


    //================================================================//
    //======================    DATA SYNCHRONIZER    =================//
    //================================================================//
    DATA_SYNC #(
        .BUS_WIDTH(DATA_WIDTH)
                                ) DATA_SYNC_U1 (
        .unsync_bus(TX_P_DATA),
        .bus_enable(TX_D_VLD),
        .dest_clk(TX_CLK),
        .dest_rst(SYNC_RST_UART),
        .sync_bus(SYNC_TX_P_DATA),
        .enable_pulse_d(SYNC_TX_D_VLD)
    );


    DATA_SYNC #(
        .BUS_WIDTH(DATA_WIDTH)
                                ) DATA_SYNC_U2 (
        .unsync_bus(RX_P_DATA),
        .bus_enable(RX_D_VLD),
        .dest_clk(REF_CLK),
        .dest_rst(SYNC_RST_REF),
        .sync_bus(SYNC_RX_P_DATA),
        .enable_pulse_d(SYNC_RX_D_VLD)
    );


    //================================================================//
    //======================    RST SYNCHRONIZER    ==================//
    //================================================================//
    RST_SYNC RST_SYNC_U1 (
        .CLK(REF_CLK),
        .RST(RST),
        .SYNC_RST(SYNC_RST_REF)
    );


    RST_SYNC RST_SYNC_U2 (
        .CLK(UART_CLK),
        .RST(RST),
        .SYNC_RST(SYNC_RST_UART)
    );


    //================================================================//
    //================================================================//
    //================================================================//


endmodule