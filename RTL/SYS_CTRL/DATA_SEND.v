`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2024 06:50:05 AM
// Design Name: 
// Module Name: DATA_SEND (CRTL_SYS)
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
module DATA_SEND #(
    parameter DATA_WIDTH = 8
    ) (
    input   wire                            CLK,
    input   wire                            RST,
    input   wire    [1            : 0]      send_ctrl_sig,
    input   wire    [DATA_WIDTH-1 : 0]      alu_out,
    input   wire    [DATA_WIDTH-1 : 0]      reg_rd_data,
    output  reg     [DATA_WIDTH-1 : 0]      tx_in,
    output  reg                             tx_data_vld
    );


    always @(posedge CLK, negedge RST)
    begin
        if(~RST) begin
            tx_in       <=  'b0;
            tx_data_vld <= 1'b0;
        end
        else begin
            case(send_ctrl_sig)
                2'b10:  begin // alu_out_to_tx (first word)
                            tx_in       <= alu_out;
                            tx_data_vld <= 1'b1;
                        end
                2'b01:  begin // alu_out_to_tx (second word)
                            tx_in       <= alu_out;
                            tx_data_vld <= 1'b1;
                        end
                2'b11:  begin // reg_out_to_tx
                            tx_in       <= reg_rd_data;
                            tx_data_vld <= 1'b1;
                        end
                default:begin
                            tx_in       <= tx_in;
                            tx_data_vld <= 1'b0;    //tx_data_vls is pulse
                        end
            endcase
        end
    end



endmodule
