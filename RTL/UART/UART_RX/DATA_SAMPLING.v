`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2024 03:57:25 AM
// Design Name: 
// Module Name: DATA_SAMPLING (UART-RX)
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
module DATA_SAMPLING #(
    parameter EDGE_CNT_WIDTH  = 3,
    parameter PRESCALE_WIDTH  = 5 
    ) (
    input   wire                                CLK,
    input   wire                                RST,
    input   wire                                S_DATA,
    input   wire    [EDGE_CNT_WIDTH-1 : 0]      edge_cnt,
    input   wire                                sample_en,
    input   wire    [PRESCALE_WIDTH-1 : 0]      prescale,
    output  reg                                 sampled_bit
    );

    reg             [2                : 0]      bit_samples;
    reg             [2                : 0]      ones_num;

    wire            [PRESCALE_WIDTH-1 : 0]      half_prescale;

    wire            [PRESCALE_WIDTH-1 : 0]      edge_before_mid;
    wire            [PRESCALE_WIDTH-1 : 0]      edge_mid;
    wire            [PRESCALE_WIDTH-1 : 0]      edge_after_mid;


    assign half_prescale    = prescale>>1;
    assign edge_mid         = half_prescale - 1;
    assign edge_before_mid  = edge_mid - 1;
    assign edge_after_mid   = edge_mid + 1;
    

    always @(posedge CLK, negedge RST)
    begin
        if(~RST)
            bit_samples <= 'b0;
        else if(sample_en) begin
            if(edge_cnt == edge_before_mid)         // sample before the middle
                bit_samples[0] <= S_DATA;
            else if(edge_cnt == edge_mid)           // sample at the middle
                bit_samples[1] <= S_DATA;
            else if(edge_cnt == edge_after_mid)     // sample after the middle
                bit_samples[2] <= S_DATA;
            else
                bit_samples <= bit_samples;
        end
        else
            bit_samples <= bit_samples;
    end


    always @(*)
    begin
        ones_num    = bit_samples[0] + bit_samples[1] + bit_samples[2];  // Number of ONEs in the bit_samples
        sampled_bit = (ones_num > 'b1) ? 1'b1 : 1'b0;
    end



endmodule
