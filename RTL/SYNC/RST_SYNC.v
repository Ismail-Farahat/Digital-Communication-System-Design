`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2024 05:47:55 AM
// Design Name: 
// Module Name: RST_SYNC (ACTIVE LOW)
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
module RST_SYNC(
    input   wire    CLK,
    input   wire    RST,
    output  wire    SYNC_RST
    );

    reg             q_sync1,
                    q_sync2;


    always @(posedge CLK, negedge RST)
    begin
        if (~RST) begin
            q_sync1 <= 0;
            q_sync2 <= 0;
        end
        else begin
            q_sync1 <= 1;
            q_sync2 <= q_sync1;
        end
    end


    assign SYNC_RST = q_sync2;



endmodule
