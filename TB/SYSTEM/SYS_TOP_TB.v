`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2024 06:45:06 AM
// Design Name: 
// Module Name: SYS_TOP_TB
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
module SYS_TOP_TB();


    //================================================================//
    //======================    PARAMETERS    ========================//
    //================================================================//
    // DUT Parameters
    localparam DATA_WIDTH       = 8;
    localparam ALU_OUT_WIDTH    = 2*DATA_WIDTH;
    localparam ADDR_WIDTH       = 4;
    localparam ALU_FUN_WIDTH    = 4;
    localparam PRESCALE_WIDTH   = 5;
    localparam DIV_RATIO_WIDTH  = 4;

    // CLock Parameters
    localparam REF_CLK_PERIOD   = 0.2;                      // freq = 500 MHz (REQUIRED: 50  MHz)
    localparam UART_CLK_PERIOD  = 0.9;                      // freq = 100 MHz (REQUIRED: 9.6 KHz)
    localparam T                = 8 * UART_CLK_PERIOD;      // The data will be sent w.r.t this period

    // Tests Configuration
    localparam par_config       = 2'b0_1;                   // PAR_CONFIG[0] = enable, PAR_CONFIG[1] = type
    localparam FRM_WIDTH        = par_config[0] ? DATA_WIDTH+3 : DATA_WIDTH+2;
    localparam max_cmd_width    = 4*DATA_WIDTH;
    

    
    //================================================================//
    //======================    SIGNALS DECLRATION    ================//
    //================================================================//
    reg     REF_CLK;
    reg     UART_CLK;
    reg     RST;
    reg     RX_IN;
    wire    TX_OUT;
    wire    PAR_ERR;
    wire    FRM_ERR;



    //================================================================//
    //======================    DUT INTERNAL SIGNALS (DEBUG)    ======//
    //================================================================//
    // State
    wire    [3                 : 0]     state;
    wire    [2                 : 0]     cmd_code;
    // RX
    wire    [DATA_WIDTH-1      : 0]     RX_P_DATA;
    wire                                RX_D_VLD;
    wire    [DATA_WIDTH-1      : 0]     SYNC_RX_P_DATA;
    wire                                SYNC_RX_D_VLD;
    // ALU
    wire                                CLK_EN;
    wire                                ALU_EN;
    wire    [ALU_FUN_WIDTH-1   : 0]     ALU_FUN;
    wire    [DATA_WIDTH-1      : 0]     operand1;
    wire    [DATA_WIDTH-1      : 0]     operand2;
    wire    [ALU_OUT_WIDTH-1   : 0]     ALU_OUT;
    wire                                ALU_OUT_VLD;
    // REG
    wire    [ADDR_WIDTH-1      : 0]     address;
    wire                                WrEN;
    wire    [DATA_WIDTH-1      : 0]     WrData;
    wire                                RdEn;
    wire    [DATA_WIDTH-1      : 0]     RdData;
    wire                                RdData_valid;
    // TX
    wire                                TX_CLK;
    wire    [DATA_WIDTH-1      : 0]     TX_P_DATA;
    wire                                TX_D_VLD;
    wire                                TX_BUSY;
    wire    [DATA_WIDTH-1      : 0]     SYNC_TX_P_DATA;
    wire                                SYNC_TX_D_VLD;
    wire                                SYNC_TX_BUSY;

    // INTERNAL NETS ASSIGNMENTS
    assign  TX_CLK          = DUT.TX_CLK;
    assign  state           = DUT.CTRL_U0.FSM_U.state;
    assign  cmd_code        = DUT.CTRL_U0.FSM_U.cmd_code;

    assign  RX_P_DATA       = DUT.RX_P_DATA;
    assign  RX_D_VLD        = DUT.RX_D_VLD;
    assign  SYNC_RX_P_DATA  = DUT.SYNC_RX_P_DATA;
    assign  SYNC_RX_D_VLD   = DUT.SYNC_RX_D_VLD;

    assign  CLK_EN          = DUT.CLK_EN;
    assign  ALU_EN          = DUT.ALU_EN;
    assign  ALU_FUN         = DUT.ALU_FUN;
    assign  operand1        = DUT.operand1;
    assign  operand2        = DUT.operand2;
    assign  ALU_OUT         = DUT.ALU_OUT;
    assign  ALU_OUT_VLD     = DUT.ALU_OUT_VLD;

    assign  address         = DUT.address;
    assign  WrEN            = DUT.WrEN;
    assign  RdEn            = DUT.RdEn;
    assign  WrData          = DUT.WrData;
    assign  RdData          = DUT.RdData;
    assign  RdData_valid    = DUT.RdData_valid;

    assign  TX_P_DATA       = DUT.TX_P_DATA;
    assign  TX_D_VLD        = DUT.TX_D_VLD;
    assign  TX_BUSY         = DUT.TX_BUSY;
    assign  SYNC_TX_P_DATA  = DUT.SYNC_TX_P_DATA;
    assign  SYNC_TX_D_VLD   = DUT.SYNC_TX_D_VLD;
    assign  SYNC_TX_BUSY    = DUT.SYNC_TX_BUSY;



    //================================================================//
    //======================    FUNCTIONS    =========================//
    //================================================================//
    function [DATA_WIDTH+2 : 0] create_frame_p;
        input   [DATA_WIDTH-1 : 0]  data;
        
        reg                         strt_bit;
        reg                         par_bit;
        reg                         stp_bit;

        begin
            strt_bit = 1'b0;
            stp_bit = 1'b1;
            par_bit = par_config[1] ? ~^data : ^data;
            create_frame_p = {stp_bit, par_bit, data, strt_bit}; //FRAME FORMAT: stp_par_data_strt
        end
    endfunction


    function [DATA_WIDTH+1 : 0] create_frame;
        input [DATA_WIDTH-1 : 0] data;
        
        begin
            create_frame = {1'b1, data, 1'b0};
        end
    endfunction



    //================================================================//
    //======================    TASKS    =============================//
    //================================================================//
    task create_cmd_stream (input [max_cmd_width-1 : 0] cmd);
        
        reg [DATA_WIDTH-1 : 0] cmd_1, cmd_2, cmd_3, cmd_4;
        reg [FRM_WIDTH-1  : 0] cmd_frm_1, cmd_frm_2, cmd_frm_3, cmd_frm_4;
        integer i;
        
        begin
            cmd_1        = cmd[31 : 24];
            cmd_2        = cmd[24 : 16];
            cmd_3        = cmd[15 : 8];
            cmd_4        = cmd[7  : 0];
            
            cmd_frm_1    = par_config[0] ? create_frame_p(cmd_1) : create_frame(cmd_1);
            cmd_frm_2    = par_config[0] ? create_frame_p(cmd_2) : create_frame(cmd_2);
            cmd_frm_3    = par_config[0] ? create_frame_p(cmd_3) : create_frame(cmd_3);
            cmd_frm_4    = par_config[0] ? create_frame_p(cmd_4) : create_frame(cmd_4);

            
            //
            if(0 || cmd_1) begin
                for (i=0; i<FRM_WIDTH; i=i+1) begin
                    #T RX_IN = cmd_frm_1[i];
                end
            end
            
            //
            if((0 || cmd_2) | (0 || cmd_1)) begin
                for (i=0; i<FRM_WIDTH; i=i+1) begin
                    #T RX_IN = cmd_frm_2[i];
                end
            end
            
            //
            for (i=0; i<FRM_WIDTH; i=i+1) begin
                #T RX_IN = cmd_frm_3[i];
            end
            
            //
            for (i=0; i<FRM_WIDTH; i=i+1) begin
                #T RX_IN = cmd_frm_4[i];
            end
            
        end
    endtask



    //================================================================//
    //======================    DUT    ===============================//
    //================================================================//
    SYSTEM_TOP #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .ALU_FUN_WIDTH(ALU_FUN_WIDTH),
        .PRESCALE_WIDTH(PRESCALE_WIDTH),
        .DIV_RATIO_WIDTH(DIV_RATIO_WIDTH)
                                            ) DUT (
        .REF_CLK(REF_CLK),
        .UART_CLK(UART_CLK),
        .RST(RST),
        .RX_IN(RX_IN),
        .TX_OUT(TX_OUT),
        .PAR_ERR(PAR_ERR),
        .FRM_ERR(FRM_ERR)
    );



    //================================================================//
    //======================    TESTS    =============================//
    //================================================================//
    // COMMANDS TESTS
    localparam CMD1_1             =  'hAA_01_8D;      // Read from REG
    localparam CMD1_2             =  'hAA_00_0D;      // Read from REG

    localparam CMD2_1             =  'hBB_01;         // Write to REG
    localparam CMD2_2             =  'hBB_00;         // Write to REG

    localparam CMD3_1             =  'hCC_05_03_00;   // ALU operation with operands (ADD)
    localparam CMD3_2             =  'hCC_08_02_03;   // ALU operation with operands (DIV)
    localparam CMD3_3             =  'hCC_04_03_02;   // ALU operation with operands (MUL)

    localparam CMD4_1             =  'hDD_01;         // ALU operation with no operands (SUB)
    localparam CMD4_2             =  'hDD_05;         // ALU operation with no operands (OR)
    localparam CMD4_3             =  'hDD_02;         // ALU operation with no operands (MUL)

    initial begin
        $dumpfile("system_top_tb_wf.vcd");
        $dumpvars(1, SYS_TOP_TB.DUT);
        // Initial Values
        RST         = 1'b0;
        REF_CLK     = 1'b0;
        UART_CLK    = 1'b0;
        RX_IN       = 1'b1;

        #(UART_CLK_PERIOD*1.5) RST = 1'b1;

        // Tests
        //create_cmd_stream(CMD1_1);
        //create_cmd_stream(CMD1_2);

        //create_cmd_stream(CMD2_1);
        //create_cmd_stream(CMD2_2);

        //create_cmd_stream(CMD3_1);
        create_cmd_stream(CMD3_2);
        create_cmd_stream(CMD3_3);

        //create_cmd_stream(CMD4_1);
        //create_cmd_stream(CMD4_2);
        //create_cmd_stream(CMD4_3);

    end
    


    //================================================================//
    //======================    CLOCKS    ============================//
    //================================================================//
    // REF_CLK
    always #(REF_CLK_PERIOD*0.5)  REF_CLK  = ~REF_CLK;
    // UART_CLK
    always #(UART_CLK_PERIOD*0.5) UART_CLK = ~UART_CLK;

    // Simulation Time
    initial #(UART_CLK_PERIOD*1000) $finish;



    //================================================================//
    //================================================================//
    //================================================================//



endmodule