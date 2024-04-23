`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2024 05:48:20 AM
// Design Name: 
// Module Name: DATA_SYNC
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
module DATA_SYNC #(
    parameter BUS_WIDTH = 8  )(
    input  wire     [BUS_WIDTH-1 : 0]       unsync_bus,
    input  wire                             bus_enable,
    input  wire                             dest_clk,
    input  wire                             dest_rst,
    output reg      [BUS_WIDTH-1 : 0]       sync_bus,
    output reg                              enable_pulse_d
    );

    reg                                     ff_sync1;      // 1st FF in synchronizer
    reg                                     ff_sync2;      // 2st FF in synchronizer
    reg                                     en_sync;       // FF for enable pulse generator
    wire                                    en_pulse_gen;
    wire            [BUS_WIDTH-1 : 0]       mux_sync_bus;  // MUX output


    always @(posedge dest_clk, negedge dest_rst)
    begin
        if (~dest_rst) begin
            ff_sync1       <= 1'b0;
            ff_sync2       <= 1'b0;
            en_sync        <= 1'b0;
            sync_bus       <=  'b0;
            enable_pulse_d <= 1'b0;
        end
        else begin
            ff_sync1       <= bus_enable;
            ff_sync2       <= ff_sync1;
            en_sync        <= ff_sync2;
            sync_bus       <= mux_sync_bus;
            enable_pulse_d <= en_pulse_gen;
        end
    end
    

    //--------------------------------------------------------------------------------
    // polarity doesn't matter, generated when there is a change happens at bus_enable
    // assign en_pulse_gen = ff_sync2 ^ en_sync;
    //--------------------------------------------------------------------------------

    assign en_pulse_gen = ff_sync2 & ~en_sync;    // generated only at bus_enable = 1 (pulse generator)
    assign mux_sync_bus = en_pulse_gen ? unsync_bus : sync_bus;



endmodule
