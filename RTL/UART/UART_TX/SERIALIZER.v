`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2024 10:22:07 PM
// Design Name: 
// Module Name: SERIALIZER (UART-TX)
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
module SERIALIZER #(
    parameter DATA_WIDTH = 8  
    ) (
    input   wire                                    CLK,
    input   wire                                    RST,
    input   wire    [DATA_WIDTH-1         : 0]      P_DATA,
    input   wire                                    ser_en,
    output  reg                                     ser_data,
    output  reg                                     ser_done
    );

    reg             [$clog2(DATA_WIDTH)-1 : 0]      count;


    always @(posedge CLK, negedge RST)
    begin
        if(~RST) begin
            ser_data <= 1'b0;
            ser_done <= 1'b0;
            ser_done <= 1'b0;
            count    <=  'b0;
        end
        else if(ser_en) begin
            ser_data <= P_DATA[count];
            if (count == DATA_WIDTH-1) begin
                count    <= 1'b0;
                ser_done <= 1'b1;
            end
            else begin
                count    <= count + 1;
                ser_done <= 1'b0;
            end
        end
        else begin
            ser_data <= 1'b0;
            ser_done <= 1'b0;
            ser_done <= 1'b0;
            count    <=  'b0;
        end
    end




endmodule
