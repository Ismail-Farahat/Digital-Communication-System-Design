`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2024 05:09:08 PM
// Design Name: 
// Module Name: ALU
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
module ALU #(
    parameter DATA_WIDTH   = 8,
    parameter RESULT_WIDTH = 2*DATA_WIDTH,
    parameter FUN_WIDTH    = 4         
    ) (
    input   wire                            CLK,
    input   wire                            RST,
    input   wire    [DATA_WIDTH-1   : 0]    A,
    input   wire    [DATA_WIDTH-1   : 0]    B,
    input   wire    [FUN_WIDTH-1    : 0]    ALU_FUN,
    input   wire                            enable,
    output  reg     [RESULT_WIDTH-1 : 0]    ALU_OUT,
    output  reg                             OUT_VALID
    );


    wire            [RESULT_WIDTH-1 : 0]    mul_res;
    wire            [RESULT_WIDTH-1 : 0]    div_res;
    wire                                    div_out_error;



    always @(posedge CLK, negedge RST)
    begin
        if (~RST) begin
            ALU_OUT   <=  'b0;
            OUT_VALID <= 1'b0;
        end
        else if (enable) begin
            case(ALU_FUN)
                4'b0000: ALU_OUT <= A + B;
                4'b0001: ALU_OUT <= A - B;
                4'b0010: ALU_OUT <= mul_res;  // ? // A*B
                4'b0011: ALU_OUT <= div_res;  // ? // A/B
                4'b0100: ALU_OUT <= A & B;
                4'b0101: ALU_OUT <= A | B;
                4'b0110: ALU_OUT <= ~(A & B);
                4'b0111: ALU_OUT <= ~(A | B);
                4'b1000: ALU_OUT <= A ^ B;
                4'b1001: ALU_OUT <= ~(A ^ B);
                4'b1010: ALU_OUT <= (A == B) ? 'b11 : 'b00;
                4'b1011: ALU_OUT <= (A > B)  ? 'b01 : 'b10;
                4'b1100: ALU_OUT <= A>>1;
                4'b1101: ALU_OUT <= A<<1;
                default: ALU_OUT <= {DATA_WIDTH{1'b0}};
            endcase
            OUT_VALID <= (ALU_FUN == 4'b0011) ? ~div_out_error : 1'b1;      // 4'b011  => div operation
        end
        else
            OUT_VALID <= 1'b0;
    end



    unsigned_divider #(
        .N(DATA_WIDTH)
                                        ) DIV_U (                                                                        
        .clk(CLK),
        .rst_n(RST),
        .in1(A),
        .in2(B),
        .start_div(enable), 
        .div_out(div_res[DATA_WIDTH-1 : 0]),
        .remainder(div_res[2*DATA_WIDTH-1 : DATA_WIDTH]),
        .error(div_out_error)
    ); 



    signed_multiplier #(
        .N(DATA_WIDTH)
                            ) MUL_U (
        .CLK(CLK),
        .RST(RST),
        .en(enable),
        .A(A),
        .B(B),
        .out_res(mul_res)
    );



endmodule
