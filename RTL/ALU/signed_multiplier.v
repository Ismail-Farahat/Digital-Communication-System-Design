`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 04:10:57 PM
// Design Name: 
// Module Name: signed_multiplier
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
module signed_multiplier #(N = 8) (
    input   wire                    CLK,
    input   wire                    RST,
    input   wire                    en,
    input   wire    [N-1    : 0]    A,
    input   wire    [N-1    : 0]    B,
    output  reg     [2*N-1  : 0]    out_res
    );


    reg             [N      : 0]    Q;   // extra bit for Qn+1
    reg             [N-1    : 0]    AC;

    integer                         i;   // for loop


    always @(posedge CLK, negedge RST)
    begin
        if(~RST)
            out_res <= 'b0;
        else if(en)
            out_res <= $signed({AC, Q[N:1]});
        else
            out_res <= out_res;
    end


    // Booth's Multiplication Algorithm
    always @(*)
    begin
        AC      = 'b0;
        Q[N:1]  = A;
        Q[0]    = 0;

        for (i=0; i<N; i=i+1) begin             // loop over operator width
            if ((Q[1] == 1) & (Q[0] == 0))      // Qn Qn+1 = Q[1] Q[0]
                AC = AC + ~B + 1;
            else if ((Q[1] == 0) & (Q[0] == 1))
                AC = AC + B;
            else
                AC = AC;
                
            //
            {AC, Q} = $signed({AC, Q}) >>> 1;
        end
    end
    
    
    
endmodule
