`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2024 09:25:47 PM
// Design Name: 
// Module Name: UART_TX_TB
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
module UART_TX_TB();


    //================================================================//
    //======================    PARAMETERS    ========================//
    //================================================================//
    localparam DATA_WIDTH     = 8;
    
    localparam CLK_PERIOD     = 4;

    // TB CONFIG
    localparam PAR_CONFIG     = 2'b0_1;            // PAR_CONFIG[0] = enable, PAR_CONFIG[1] = type



    //================================================================//
    //======================    SIGNALS DECLRATION    ================//
    //================================================================//
    reg                      CLK;
    reg                      RST;
    reg                      PAR_EN;
    reg                      PAR_TYP;
    reg  [DATA_WIDTH-1 : 0]  P_DATA;
    reg                      DATA_VALID;
    wire                     S_DATA;
    wire                     busy;
    


    //================================================================//
    //======================    DUT    ===============================//
    //================================================================//
    UART_TX DUT (
        .CLK(CLK),
        .RST(RST),
        .PAR_EN(PAR_EN),
        .PAR_TYP(PAR_TYP),
        .P_DATA(P_DATA),
        .DATA_VALID(DATA_VALID),
        .S_DATA(S_DATA),
        .busy(busy)
    );



    //================================================================//
    //======================    CLOCKS    ============================//
    //================================================================//
    // Simulation Time
    initial #(CLK_PERIOD*50) $finish;
    

    initial begin
        RST        = 0;
        CLK        = 0;
        P_DATA     = 8'b0;  // IDLE
        DATA_VALID = 1'b0;  // IDLE
        // parity config
        PAR_EN     = PAR_CONFIG[0];
        PAR_TYP    = PAR_CONFIG[1];
        // clock
        forever #(CLK_PERIOD*0.5) CLK = ~CLK;
    end
    


    //================================================================//
    //======================    TESTS    =============================//
    //================================================================//
    initial begin 
        #(CLK_PERIOD*2)  RST = 1;
        #(CLK_PERIOD*1.5)  DATA_VALID = 1'b0; P_DATA = 8'h0;
        
        //one sperated signal test
        #CLK_PERIOD        DATA_VALID = 1'b1; P_DATA = 8'h81;
        #CLK_PERIOD        DATA_VALID = 1'b0; P_DATA = 8'h81;
        #(CLK_PERIOD*14)   DATA_VALID = 1'b0; P_DATA = 8'h00;
        
        //two concurrent signals test
        #CLK_PERIOD        DATA_VALID = 1'b1; P_DATA = 8'h0A; // first signal
        #CLK_PERIOD        DATA_VALID = 1'b0; P_DATA = 8'h0A;
        #(CLK_PERIOD*11)   DATA_VALID = 1'b1; P_DATA = 8'h91; // second signal, should be declared after 11 pulses (width of data)
        #CLK_PERIOD        DATA_VALID = 1'b0; P_DATA = 8'h91;
        
        #(CLK_PERIOD*10)   DATA_VALID = 1'b0; P_DATA = 8'h0;

    end



    //================================================================//
    //================================================================//
    //================================================================//


endmodule
