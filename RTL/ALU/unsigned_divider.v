`timescale 1ns / 1ps                                                                           
//////////////////////////////////////////////////////////////////////////////////             
// Company:                                                                                    
// Engineer:                                                                                   
//                                                                                             
// Create Date: 01/02/2024 12:04:59 AM                                                         
// Design Name:                                                                                
// Module Name: unsigned_divider                                                                
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
module unsigned_divider #(parameter N=8) (                                                                        
    input                           clk,                                                                             
    input                           rst_n,                                                                         
    input           [N-1 : 0]       in1,                                                                      
    input           [N-1 : 0]       in2,                                                                      
    input                           start_div,                                                                       
    output  reg     [N-1 : 0]       div_out,                                                                 
    output  reg     [N-1 : 0]       remainder,                                                              
    output  reg                     error                                                                     
    );                                                                                         
                                                                                               
    reg                             err;
    reg             [N-1 : 0]       M;      // Divisor                                                              
    reg             [N-1 : 0]       Q;      // Dividend (will contian the value of the Qoutient)                    
    reg             [2*N : 0]       A;      // will contian the value of the Reminader    
                                            // The vector width of A is doubled to ensure no error as ..
                                            // .. some processes can take more bits ( A = A - M $ A = A + M)
                                            // .. especially at corner cases as using max allowed numbers as inputs                   
                                                                                                                                                                    
    integer                         i;      // for loop parameters     

                                                                                               
    always @(posedge clk, negedge rst_n)                                                                      
    begin                                                                                      
        if (~rst_n) begin                                                                    
            div_out   <= 0;                                                                            
            remainder <= 0;
            error     <= 0;                                                                                                                             
        end
        else if(start_div)begin
            div_out   <= Q;                                                                            
            remainder <= A[N-1:0];   // only take the first N bits of A as output remainder (size of A is 2*N)
            error     <= err;
        end                                                                                                                                                              
    end       
    

    always @(*)
    begin
        if (in2 == 0 | (in1 == 0 & in2 == 0)) begin
            // Possible errors:
            // 1) divide by zero (result should be infinity)  --> in2 = 0
            // 2) divide zero by zero ( undefined value)      --> in1 = 0, in2 = 0
            err  = 1;
            Q    = 0;
            A    = 0;
        end
        else begin
            err = 0;
            // Booth's Algorithm
            // Intiailization
            Q   = in1;
            M   = in2;
            A   = 0;
                
            for(i=0;i<N;i=i+1)begin   
                A        = {A[N-2:0], Q[N-1]};  // {A, Q} shift left
                Q[N-1:1] = Q[N-2:0];            // Q shift left
                A        = A - M;
                if (A[2*N] == 1) begin          // check if A is negative number
                    Q[0] = 0;        
                    A    = A + M;
                end                   
                else                  
                    Q[0] = 1;
            end
        end
    end                                                                               



endmodule
