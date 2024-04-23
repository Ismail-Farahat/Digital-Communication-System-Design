`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2024 06:47:28 AM
// Design Name: 
// Module Name: FRM_ANLZ (CRTL_SYS)
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
module FRM_ANLZ #(
    parameter DATA_WIDTH    = 8,
    parameter ADDR_WIDTH    = 4,
    parameter ALU_FUN_WIDTH = 4   
    ) (
    input   wire                            CLK,
    input   wire                            RST,
    input   wire    [DATA_WIDTH-1    : 0]   rx_data_out,
    input   wire                            cmd_analyze_en,
    input   wire    [1               : 0]   block_dir,
    input   wire    [1               : 0]   addr_code,
    output  reg     [2               : 0]   cmd_code,
    output  reg     [ALU_FUN_WIDTH-1 : 0]   alu_fun,
    output  reg     [DATA_WIDTH-1    : 0]   reg_wr_data,
    output  reg     [ADDR_WIDTH-1    : 0]   reg_addr
    );

    reg             [ADDR_WIDTH-1    : 0]   addr_out;


    always @(posedge CLK, negedge RST)
    begin
        if(~RST) begin
            cmd_code     <= 'h0;
            alu_fun      <= 'h0;
            reg_wr_data  <= 'h0;
            reg_addr     <= 'h0;
        end
        else if(cmd_analyze_en) begin
            case(rx_data_out)
                'hAA:   cmd_code <= 3'b001;     //reg write command
                'hBB:   cmd_code <= 3'b010;     //reg read command
                'hCC:   cmd_code <= 3'b011;     //alu fun command with operands
                'hDD:   cmd_code <= 3'b100;     //alu fun command with no operands
                default:cmd_code <= 3'b000;
            endcase
        end
        else begin
            case(block_dir)     // to direect the data frames from RX
                2'b00   :begin
                            alu_fun      <= 'h0;
                            reg_wr_data  <= 'h0;
                            reg_addr     <= 'hFF;
                        end
                2'b01:  begin // alu_fun (TO ALU)
                            alu_fun      <= rx_data_out[3:0];
                            reg_wr_data  <= reg_wr_data;
                            reg_addr     <= reg_addr;
                        end
                2'b10:  begin // reg_addr (TO REG ADDRESS PINS)
                            alu_fun      <= alu_fun;
                            reg_wr_data  <= reg_wr_data;
                            reg_addr     <= addr_out;
                        end
                2'b11:  begin // reg_wr_data (TO REG DATA PINS)
                            alu_fun      <= alu_fun;
                            reg_wr_data  <= rx_data_out;
                            reg_addr     <= reg_addr;
                        end
                default:begin
                            alu_fun      <= 'h0;
                            reg_wr_data  <= 'h0;
                            reg_addr     <= 'hFF;
                        end
            endcase
        end
    end


    always @(*)
    begin
        case(addr_code) // to detemine address of based on given command
            2'b01:    addr_out = rx_data_out;   // any write or read address (not 0x0 or 0x1)
            2'b10:    addr_out = 'h00;          // operand 1 address
            2'b11:    addr_out = 'h01;          // operand 2 address
            default:  addr_out = rx_data_out;
        endcase
    end



endmodule
