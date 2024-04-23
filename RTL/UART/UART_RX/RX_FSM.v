`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2024 03:57:50 AM
// Design Name: 
// Module Name: RX_FSM (UART-RX)
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
module RX_FSM #(
    parameter BIT_CNT_WIDTH   = 4,
    parameter EDGE_CNT_WIDTH  = 3
    ) (
    input   wire                                CLK,
    input   wire                                RST,
    input   wire                                S_DATA,
    input   wire                                PAR_EN,
    input   wire    [BIT_CNT_WIDTH-1  : 0]      bit_cnt,
    input   wire    [EDGE_CNT_WIDTH-1 : 0]      edge_cnt,
    input   wire                                par_err,
    input   wire                                stp_err,
    input   wire                                strt_glitch,
    output  reg                                 sample_en, 
    output  reg                                 cnt_en,
    output  reg                                 par_chk_en,
    output  reg                                 stp_chk_en,
    output  reg                                 strt_chk_en,
    output  reg                                 deser_en,
    output  reg                                 DATA_VALID
    );

    reg             [3                : 0]      state,
                                                next_state;


    // FSM states
    localparam IDLE  = 4'b000;
    localparam STRT  = 4'b001;   // check start bit state
    localparam READ  = 4'b010;
    localparam PAR   = 4'b011;   // parity check state
    localparam STP   = 4'b100;   // check stop bit state when PAR_EN = 0
    localparam STP_P = 4'b101;   // check stop bit state when PAR_EN = 1
    localparam ERR   = 4'b110;   // error state when PAR_EN = 0 
    localparam ERR_P = 4'b111;   // error state when PAR_EN = 1
    localparam VLD   = 4'b1000;  // Valid State
    


    always @(posedge CLK, negedge RST)
    begin
        if(~RST)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*)
    begin
        case(state)
            IDLE:   begin
                        //outputs
                        strt_chk_en = 1'b0;
                        cnt_en      = 1'b0;
                        sample_en   = 1'b0;
                        deser_en    = 1'b0;
                        par_chk_en  = 1'b0;
                        stp_chk_en  = 1'b0;
                        DATA_VALID  = 1'b0;
                        //next_state
                        if(!S_DATA)  //strt bit is LOW signal
                            next_state = STRT;
                        else
                            next_state = IDLE;
                    end
            STRT:   begin
                        //outputs
                        strt_chk_en = 1'b1;
                        cnt_en      = 1'b1;
                        sample_en   = 1'b1;
                        deser_en    = 1'b0;
                        par_chk_en  = 1'b0;
                        stp_chk_en  = 1'b0;
                        DATA_VALID  = 1'b0;
                        //next_state
                        if(bit_cnt == 4'h0 & edge_cnt == 3'h7)
                            next_state = !strt_glitch ? READ : IDLE;
                        else 
                            next_state = STRT;
                    end
            READ:   begin
                        //outputs
                        strt_chk_en = 1'b0;
                        cnt_en      = 1'b1;
                        sample_en   = 1'b1;
                        deser_en    = 1'b1;
                        par_chk_en  = 1'b0;
                        stp_chk_en  = 1'b0;
                        DATA_VALID  = 1'b0;
                        //next_state
                        if (bit_cnt == 4'h9 & edge_cnt == 3'h3) // current edge = 4'h8, next edge = 4'h9 - par_chk edge | stp_chk edge
                            next_state = PAR_EN ? PAR : STP;
                        else
                            next_state = READ;
                    end
            PAR :   begin
                        //outputs
                        strt_chk_en = 1'b0;
                        cnt_en      = 1'b1;
                        sample_en   = 1'b1;
                        deser_en    = 1'b0;
                        par_chk_en  = 1'b1;
                        stp_chk_en  = 1'b0;
                        DATA_VALID  = 1'b0;
                        //next_state
                        if (bit_cnt == 4'hA & edge_cnt == 3'h3) // current edge = 4'h9, next edge = 4'hA - stp_chk edge
                            next_state = STP_P;
                        else
                            next_state = PAR;
                    end
            STP :   begin
                        //outputs
                        strt_chk_en = 1'b0;
                        cnt_en      = 1'b1;
                        sample_en   = 1'b1;
                        deser_en    = 1'b0;
                        par_chk_en  = 1'b0;
                        stp_chk_en  = 1'b1;
                        DATA_VALID  = 1'b0;
                        //next_state
                        if (bit_cnt == 4'h9 & edge_cnt == 3'h5) 
                            next_state = ERR;
                        else
                            next_state = STP;
                    end
            STP_P:  begin
                        //outputs
                        strt_chk_en = 1'b0;
                        cnt_en      = 1'b1;
                        sample_en   = 1'b1;
                        deser_en    = 1'b0;
                        par_chk_en  = 1'b0;
                        stp_chk_en  = 1'b1;
                        DATA_VALID  = 1'b0;
                        //next_state
                        if (bit_cnt == 4'hA & edge_cnt == 3'h5)
                            next_state = ERR_P;
                        else
                            next_state = STP_P;
                    end
            ERR :   begin
                        //outputs
                        strt_chk_en = 1'b0;
                        cnt_en      = 1'b0;
                        sample_en   = 1'b0;
                        deser_en    = 1'b0;
                        par_chk_en  = 1'b0;
                        stp_chk_en  = 1'b0;
                        DATA_VALID  = 1'b0;
                        //next_state
                        if (~stp_err)
                            next_state = VLD;
                        else
                            next_state = !S_DATA ? STRT : IDLE;
                    end
            ERR_P:  begin
                        //outputs
                        strt_chk_en = 1'b0;
                        cnt_en      = 1'b0;
                        sample_en   = 1'b0;
                        deser_en    = 1'b0;
                        par_chk_en  = 1'b0;
                        stp_chk_en  = 1'b0;
                        DATA_VALID  = 1'b0;
                        //next_state
                        if (~par_err & ~stp_err)
                            next_state = VLD;
                        else
                            next_state = !S_DATA ? STRT : IDLE;
                    end
            VLD :   begin
                        //outputs
                        strt_chk_en = 1'b0;
                        cnt_en      = 1'b0;
                        sample_en   = 1'b0;
                        deser_en    = 1'b0;
                        par_chk_en  = 1'b0;
                        stp_chk_en  = 1'b0;
                        DATA_VALID  = 1'b1;
                        //next_state
                        if(!S_DATA)
                            next_state = STRT;
                        else
                            next_state = IDLE;
                    end
            default:begin
                        //outputs
                        strt_chk_en = 1'b0;
                        cnt_en      = 1'b0;
                        sample_en   = 1'b0;
                        deser_en    = 1'b0;
                        par_chk_en  = 1'b0;
                        stp_chk_en  = 1'b0;
                        DATA_VALID  = 1'b0;
                        //next_state
                        next_state  = IDLE;
                    end
        endcase
    end



endmodule
