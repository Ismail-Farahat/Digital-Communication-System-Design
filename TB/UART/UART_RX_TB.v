`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2024 06:45:06 PM
// Design Name: 
// Module Name: UART_RX_TB
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
module UART_RX_TB();


    //================================================================//
    //======================    PARAMETERS    ========================//
    //================================================================//
    localparam DATA_WIDTH     = 8;
    localparam PRESCALE_WIDTH = 5;
    localparam PRESCALE_VAL   = 5'b01000;
    
    localparam S_DATA_WIDTH_P = DATA_WIDTH + 3;   // S_DATA with parity
    localparam S_DATA_WIDTH   = DATA_WIDTH + 2;   // S_DATA without parity
    
    localparam CLK_PERIOD     = 1;
    
    
    // TB CONFIG
    localparam PAR_CONFIG     = 2'b0_1;             // PAR_CONFIG[0] = enable, PAR_CONFIG[1] = type
    localparam S_DATA_VAL_P   =  'b1_1_01111010_0;  // stp_par_data_strt, 1_1_7A_0, test data with parity
    localparam S_DATA_VAL     =  'b1_01111011_0;    // stp_data_strt, 1_7B_0,       test data without parity
    
    
    //================================================================//
    //======================    SIGNALS DECLRATION    ================//
    //================================================================//
    reg                            CLK;
    reg                            RST;
    reg                            PAR_EN;
    reg                            PAR_TYP;
    reg                            S_DATA;
    reg    [PRESCALE_WIDTH-1 : 0]  PRESCALE;
    wire   [DATA_WIDTH-1     : 0]  P_DATA;
    wire                           DATA_VALID;
    wire                           PAR_ERR;
    wire                           STP_ERR;


    //================================================================//
    //======================    DUT    ===============================//
    //================================================================//
    UART_RX DUT (
        .CLK(CLK),
        .RST(RST),
        .PAR_EN(PAR_EN),
        .PAR_TYP(PAR_TYP),
        .S_DATA(S_DATA),
        .PRESCALE(PRESCALE),
        .P_DATA(P_DATA),
        .DATA_VALID(DATA_VALID),
        .PAR_ERR(PAR_ERR),
        .STP_ERR(STP_ERR)
    );


    //================================================================//
    //======================    CLOCKS    ============================//
    //================================================================//
    // Simulation Time
    initial #(CLK_PERIOD*1000) $finish;
    

    initial begin
        RST      = 0;
        CLK      = 0;
        S_DATA   = 1'b1;  // IDLE
        // par config
        PAR_EN   = PAR_CONFIG[0];
        PAR_TYP  = PAR_CONFIG[1];
        PRESCALE = PRESCALE_VAL;
        // clock
        forever #(CLK_PERIOD*0.5) CLK = ~CLK;
    end
    
    
    

    //================================================================//
    //======================    TESTS    =============================//
    //================================================================//
    integer i, j;  //for loop
    initial begin 
        #(CLK_PERIOD*2)    RST = 1;
        #(CLK_PERIOD*1.5)  S_DATA = 1'b1;
        
        ////////////////////////////////////////////////////////////////////////
        /////////////////////////    Operation TEST    /////////////////////////
        ////////////////////////////////////////////////////////////////////////
        /*
        if(PAR_EN) begin
            for (i=0; i<S_DATA_WIDTH_P-1; i=i+1) begin
                #(8*CLK_PERIOD) S_DATA = S_DATA_VAL_P[i];
            end
        end
        else begin
            for (i=0; i<S_DATA_WIDTH; i=i+1) begin
                #(8*CLK_PERIOD) S_DATA = S_DATA_VAL[i];
            end
        end
        */
        ////////////////////////////////////////////////////////////////////////
        /////////////////////////    Cascading Frames TEST    //////////////////
        ////////////////////////////////////////////////////////////////////////
        
        for (j=0; j<9; j=j+1) begin
            for (i=0; i<S_DATA_WIDTH_P; i=i+1) begin
                #(8*CLK_PERIOD) S_DATA = S_DATA_VAL_P[i];
            end
        end
        
        
        
        ///////////////////////////////////////////////////////////////////////
        /////////////////////////    Sampling TEST    /////////////////////////
        ///////////////////////////////////////////////////////////////////////
        /*
        for (i=0; i<S_DATA_WIDTH_P-1; i=i+1) begin
            if (i == 3) begin
                // bit 2 (sampling will be tested on this bit)
                #CLK_PERIOD     S_DATA =  S_DATA_VAL_P[i-1];  //bit2 [1]
                #CLK_PERIOD     S_DATA =  S_DATA_VAL_P[i-1];  //bit2 [2]
                #CLK_PERIOD     S_DATA =  S_DATA_VAL_P[i-1];  //bit2 [3]
                ////////////////////////////////////////////////////////
                ///////////////    bit_samples_vector    ///////////////
                // at least two of them equal S_DATA_VAL_P[i-1]
                #CLK_PERIOD     S_DATA =  S_DATA_VAL_P[i-1];  //bit2 [4]  --> bit_samples[0]
                #CLK_PERIOD     S_DATA =  S_DATA_VAL_P[i-1];  //bit2 [5]  --> bit_samples[1]
                #CLK_PERIOD     S_DATA = ~S_DATA_VAL_P[i-1];  //bit2 [6]  --> bit_samples[2]
                ////////////////////////////////////////////////////////
                #CLK_PERIOD     S_DATA =  S_DATA_VAL_P[i-1];  //bit2 [7]
                // bit 3
                #CLK_PERIOD     S_DATA =  S_DATA_VAL_P[i];    //bit3 [0]
            end
            else begin
                #(8*CLK_PERIOD) S_DATA =  S_DATA_VAL_P[i];
            end
        end
        */
    end
    


    //================================================================//
    //================================================================//
    //================================================================//

    
endmodule
