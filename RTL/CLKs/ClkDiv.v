`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2024 05:46:48 AM
// Design Name: 
// Module Name: ClkDiv
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
module ClkDiv #(
    parameter RATIO_WIDTH = 4             
    ) (
    input   wire                            i_ref_clk,
    input   wire                            i_rst,
    input   wire                            i_clk_en,
    input   wire    [RATIO_WIDTH-1 : 0]     i_div_ratio,
    output  wire                            o_div_clk
    );

    reg             [RATIO_WIDTH-1 : 0]     count;
    reg                                     div_clk;
    wire                                    is_even;
    wire                                    valid_ratio;


    always @(posedge i_ref_clk, negedge i_rst)
    begin
        if(~i_rst)
            count <= {RATIO_WIDTH{1'b1}};
        else if (i_clk_en)
            count <= (count == i_div_ratio - 1) ? 0 : count + 1;
        else
            count <= {RATIO_WIDTH{1'b1}};
    end


    always @(*)
    begin
        if (is_even) begin
            if (count < i_div_ratio>>1) begin  // i_div_ratio>>1 ,divide by 2 when i_div_ratio is even
                div_clk = 1'b1;  // the first half of the divided clock period
            end
            else begin
                div_clk = 1'b0;  // the first second of the divided clock period
            end
        end
        else begin // odd ratio
            if (count < (i_div_ratio+1)>>1) begin // i_div_ratio+1>>1 ,add one to i_div_ratio when it's odd then divide by 2
                div_clk = 1'b1;  // the first half of the divided clock period
            end
            else begin
                div_clk = 1'b0;  // the second half of the divided clock period
            end
        end
    end //always


    assign valid_ratio = (i_div_ratio != {RATIO_WIDTH{1'b0}}) & (i_div_ratio != 'b1); // ratio must not be 0 or 1
    assign is_even     = i_div_ratio[0] == 0;
    assign o_div_clk   = (i_clk_en & valid_ratio) ? div_clk : i_ref_clk;




endmodule
