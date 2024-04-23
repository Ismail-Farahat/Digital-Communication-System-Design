`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2024 02:59:15 AM
// Design Name: 
// Module Name: TX_FSM (UART-TX)
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
module TX_FSM(
    input   wire         CLK,
    input   wire         RST,
    input   wire         DATA_VALID,
    input   wire         PAR_EN,
    input   wire         ser_done,
    output  reg   [1:0]  mux_sel,
    output  reg          busy,
    output  reg          ser_en
    );

    reg  [2:0]  state, next_state;



    localparam IDLE = 2'b00;  // idle state
    localparam STRT = 2'b01;  // strt_bit tranimision state
    localparam DATA = 2'b10;  // ser_data tranimision state
    localparam PAR  = 2'b11;  // par_bit tranimision state
    

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
            IDLE:   begin //IDLE state and STOP state
                        //outputs
                        mux_sel = 2'b01;  // STOP bit will be muxed (HIGH SIGNAL)
                        busy    = 1'b0;
                        ser_en  = 1'b0;
                        //nextstate
                        next_state = DATA_VALID ? STRT : IDLE;
                    end
            STRT:   begin
                        //outputs
                        mux_sel = 2'b00;  // strt_bit will be muxed
                        busy    = 1'b1;
                        ser_en  = 1'b1;
                        //nextstate
                        next_state = DATA;
                    end
            DATA:   begin
                        //outputs
                        mux_sel = 2'b10;  //ser_data will be muxed
                        busy    = 1'b1;
                        ser_en  = 1'b1;
                        //nextstate
                        if (ser_done)
                            next_state = PAR_EN ? PAR : IDLE;
                        else
                            next_state = DATA;
                    end
            PAR:    begin
                    //outputs
                        mux_sel = 2'b11;  // PAR_BIT will be muxed
                        busy    = 1'b1;
                        ser_en  = 1'b0;
                        //nextstate
                        next_state = IDLE;
                    end
            default:begin
                        //outputs
                        mux_sel = 2'b01;  // HIGH signal will be muxed
                        busy    = 1'b0;
                        ser_en  = 1'b0;
                        //nextstate
                        next_state = IDLE;
                    end
        endcase
    end


endmodule
