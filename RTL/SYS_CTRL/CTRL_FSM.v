`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2024 06:45:53 AM
// Design Name: 
// Module Name: CTRL_FSM (CRTL_SYS)
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
module CTRL_FSM (
    input   wire                CLK,
    input   wire                RST,
    input   wire                rx_data_vld,
    input   wire                tx_busy,
    input   wire                reg_rd_data_vld,
    input   wire    [2 : 0]     cmd_code,
    input   wire                alu_out_vld,
    output  reg                 alu_en,
    output  reg                 gclk_en,
    output  reg                 cmd_analyze_en,
    output  reg     [1 : 0]     block_dir,
    output  reg     [1 : 0]     addr_code,
    output  reg     [1 : 0]     send_ctrl_sig,
    output  reg                 reg_wr_en,
    output  reg                 reg_rd_en,
    output  wire                clk_div_en
    );

    reg             [3 : 0]     state,
                                next_state;


    // FSM states
    localparam IDLE     = 4'h0;
    localparam CMD      = 4'h1;     // command analyzing state
    localparam RD_ADDR  = 4'h2;     // read from reg command state 1 (address)
    localparam REG_VLD  = 4'h3;     // read from reg command state 2 (data to send)
    localparam WR_ADDR  = 4'h4;     // write to reg command state 1 (address)
    localparam WR_DATA  = 4'h5;     // write to reg command state 2 (direct the written data to reg)
    localparam WR_DONE  = 4'h6;     // write to reg command state 3 (activating the write enable)
    localparam OP1_ADR  = 4'h7;     // ALU with operands command state [operand 1] (address)
    localparam OP1_DAT  = 4'h8;     // ALU with operands command state [operand 1] (write data)
    localparam OP2_ADR  = 4'h9;     // ALU with operands command state [operand 2] (address)
    localparam OP2_DAT  = 4'hA;     // ALU with operands command state [operand 2] (write data)
    localparam NO_OP    = 4'hB;     // ALU with no operands command state (direct to ALU once the function captured by RX)
    localparam ALU      = 4'hC;     // ALU state 1 (to read function type and do the operation)
    localparam ALU_VLD  = 4'hD;     // ALU state 2 (to send the first word of ALU result) [ALU_OUT_WIDTH = 2*DATA_WIDTH]
    localparam ALU_VLD2 = 4'hE;     // ALU state 3 (to wait untill the first word is completely sent)
    localparam ALU_VLD3 = 4'hF;     // ALU state 4 (to send the second word of ALU result)


    assign clk_div_en   = 1'b1;     // always active (from specs)


    always @(posedge CLK, negedge RST)
    begin
        if(~RST)
            state <= IDLE;
        else
            state <= next_state;
    end


    always @(*)
    begin
        case(state)
            IDLE:   begin  //S0
                        // outputs
                        cmd_analyze_en  = rx_data_vld ? 1'b1 : 1'b0;
                        block_dir       =  'b0;
                        alu_en          = 1'b0;
                        gclk_en         = 1'b0;
                        addr_code       = 2'b0;
                        reg_wr_en       = 1'b0;
                        reg_rd_en       = 1'b0;
                        send_ctrl_sig   =  'b0;
                        // next_state
                        if(rx_data_vld)
                            next_state  = CMD;
                        else
                            next_state  = IDLE;
                    end
            CMD :   begin //S1
                        // outputs
                        cmd_analyze_en  = 1'b1;
                        block_dir       =  'b0;
                        alu_en          = 1'b0;
                        gclk_en         = 1'b0;
                        addr_code       = 2'b0;
                        reg_wr_en       = 1'b0;
                        reg_rd_en       = 1'b0;
                        send_ctrl_sig   =  'b0;
                        // next_state
                        case(cmd_code)
                            3'b001:     next_state  = WR_ADDR;  //reg write command
                            3'b010:     next_state  = RD_ADDR;  //reg read command
                            3'b011:     next_state  = OP1_ADR;  //alu fun command with operands
                            3'b100:     next_state  = NO_OP;    //alu fun command with no operands
                            default:    next_state  = IDLE;     //no command
                        endcase
                    end
            RD_ADDR:begin //S2
                        // outputs
                        cmd_analyze_en  = 1'b0;
                        block_dir       = rx_data_vld ? 'b10 : 'b0;
                        alu_en          = 1'b0;
                        gclk_en         = 1'b0;
                        addr_code       = 2'b0;
                        reg_wr_en       = 1'b0;
                        reg_rd_en       = rx_data_vld ? 1'b1 : 1'b0;
                        send_ctrl_sig   = 'b0;
                        // next_state
                        if (cmd_code == 'b0)
                            next_state  = CMD;
                        else if(reg_rd_data_vld & ~tx_busy)
                            next_state  = REG_VLD;
                        else
                            next_state  = RD_ADDR;
                    end
            REG_VLD:begin //S3
                        // outputs
                        cmd_analyze_en  = 1'b0;
                        block_dir       =  'b10;
                        alu_en          = 1'b0;
                        gclk_en         = 1'b0;
                        addr_code       = 2'b0;
                        reg_wr_en       = 1'b0;
                        reg_rd_en       = 1'b1;
                        send_ctrl_sig   =  ~tx_busy ? 'b11 : 'b0;
                        // next_state
                        if (tx_busy)
                            next_state      = IDLE;
                        else
                            next_state      = REG_VLD;
                    end
            WR_ADDR:begin //S4
                        // outputs
                        cmd_analyze_en  = 1'b0;
                        block_dir       = rx_data_vld ? 'b10 : 'b0;
                        alu_en          = 1'b0;
                        gclk_en         = 1'b0;
                        addr_code       = 2'b0;
                        reg_wr_en       = 1'b0;
                        reg_rd_en       = 1'b0;
                        send_ctrl_sig   =  'b0;
                        // next_state
                        if (cmd_code == 'b0)
                            next_state  = CMD;
                        else if(rx_data_vld)
                            next_state  = WR_DATA;
                        else
                            next_state  = WR_ADDR;
                    end
            WR_DATA:begin //S5
                        // outputs
                        cmd_analyze_en  = 1'b0;
                        block_dir       = rx_data_vld ? 'b11 : 'b10;
                        alu_en          = 1'b0;
                        gclk_en         = 1'b0;
                        addr_code       = 2'b0;
                        reg_wr_en       = 1'b0;
                        reg_rd_en       = 1'b0;
                        send_ctrl_sig   =  'b0;
                        // next_state
                        if(rx_data_vld)
                            next_state  = WR_DONE;
                        else
                            next_state  = WR_DATA;
                    end
            WR_DONE:begin //S6
                        // outputs
                        cmd_analyze_en  = 1'b0;
                        block_dir       =  'b11;
                        alu_en          = 1'b0;
                        gclk_en         = 1'b0;
                        addr_code       = 2'b0;
                        reg_wr_en       = 1'b1;
                        reg_rd_en       = 1'b0;
                        send_ctrl_sig   =  'b0;
                        // next_state
                        next_state      = IDLE;
                    end
            OP1_ADR:begin //S7
                        // outputs
                        cmd_analyze_en  = 1'b0;
                        block_dir       = 'b10;
                        alu_en          = 1'b0;
                        gclk_en         = 1'b0;
                        addr_code       = 2'b10;
                        reg_wr_en       = 1'b1;
                        reg_rd_en       = 1'b0;
                        send_ctrl_sig   =  'b0;
                        // next_state
                        if (cmd_code == 'b0)
                            next_state  = CMD;
                        else if(rx_data_vld)
                            next_state  = OP1_DAT;
                        else
                            next_state  = OP1_ADR;
                        end
            OP1_DAT:begin //S8
                        // outputs
                        cmd_analyze_en  = 1'b0;
                        block_dir       =  'b11;
                        alu_en          = 1'b0;
                        gclk_en         = 1'b0;
                        addr_code       = 2'b10;
                        reg_wr_en       = 1'b1;
                        reg_rd_en       = 1'b0;
                        send_ctrl_sig   =  'b0;
                        // next_state
                        next_state      = OP2_ADR;
                    end
            OP2_ADR:begin //S9
                        // outputs
                        cmd_analyze_en  = 1'b0;
                        block_dir       = 'b10;
                        alu_en          = 1'b0;
                        gclk_en         = 1'b0;
                        addr_code       = 2'b11;
                        reg_wr_en       = 1'b1;
                        reg_rd_en       = 1'b0;
                        send_ctrl_sig   =  'b0;
                        // next_state
                        if(rx_data_vld)
                            next_state  = OP2_DAT;
                        else
                            next_state  = OP2_ADR;
                        end
            OP2_DAT:begin //S10 (A)
                        // outputs
                        cmd_analyze_en  = 1'b0;
                        block_dir       =  'b11;
                        alu_en          = 1'b0;
                        gclk_en         = 1'b0;
                        addr_code       = 2'b11;
                        reg_wr_en       = 1'b1;
                        reg_rd_en       = 1'b0;
                        send_ctrl_sig   =  'b0;
                        // next_state
                        if(rx_data_vld)
                            next_state  = ALU;
                        else
                            next_state  = OP2_DAT;
                    end
            NO_OP  :begin //S11 (B)
                        // outputs
                        cmd_analyze_en  = 1'b0;
                        block_dir       =  'b0;
                        alu_en          = 1'b0;
                        gclk_en         = 1'b0;
                        addr_code       = 2'b0;
                        reg_wr_en       = 1'b1;
                        reg_rd_en       = 1'b0;
                        send_ctrl_sig   =  'b0;
                        // next_state
                        if (cmd_code == 'b0)
                            next_state  = CMD;
                        else
                            next_state  = rx_data_vld ? ALU : NO_OP;
                    end
            ALU:    begin //S12 (C)
                        // outputs
                        cmd_analyze_en  = 1'b0;
                        block_dir       =  'b01;
                        alu_en          = 1'b1;
                        gclk_en         = 1'b1;
                        addr_code       = 2'b0;
                        reg_wr_en       = 1'b0;
                        reg_rd_en       = 1'b0;
                        send_ctrl_sig   =  'b0;
                        // next_state
                        if (alu_out_vld & ~tx_busy)
                            next_state  = ALU_VLD;
                        else
                            next_state  = ALU;
                    end
            ALU_VLD:begin //S13 (D)
                        // outputs
                        cmd_analyze_en  = 1'b0;
                        block_dir       =  'b01;
                        alu_en          = tx_busy ? 1'b0 : 1'b1;
                        gclk_en         = 1'b1;
                        addr_code       = 2'b0;
                        reg_wr_en       = 1'b0;
                        reg_rd_en       = 1'b0;
                        send_ctrl_sig   =  'b01;
                        // next_state
                        next_state      = tx_busy ? ALU_VLD2 : ALU_VLD;
                    end
            ALU_VLD2:begin //S14 (E)
                        // outputs
                        cmd_analyze_en  = rx_data_vld ? 1'b1 : 1'b0;  //analyze any comming frame to detect the next command
                        block_dir       =  'b01;
                        alu_en          = 1'b0;
                        gclk_en         = 1'b0;
                        addr_code       = 2'b0;
                        reg_wr_en       = 1'b0;
                        reg_rd_en       = 1'b0;
                        send_ctrl_sig   =  'b00;
                        // next_state
                        if(~tx_busy)
                            next_state  = ALU_VLD3;
                        else
                            next_state  = ALU_VLD2;
                    end
            ALU_VLD3:begin //S15 (F)
                        // outputs
                        cmd_analyze_en  = rx_data_vld ? 1'b1 : 1'b0;  //analyze any comming frame to detect the next command
                        block_dir       =  'b01;
                        alu_en          = 1'b0;
                        gclk_en         = 1'b0;
                        addr_code       = 2'b0;
                        reg_wr_en       = 1'b0;
                        reg_rd_en       = 1'b0;
                        send_ctrl_sig   =  'b10;
                        // next_state
                        if(tx_busy)
                            next_state  = CMD;
                        else
                            next_state  = ALU_VLD3;
                    end
            default:begin
                        // outputs
                        cmd_analyze_en  = 1'b0;
                        block_dir       =  'b0;
                        alu_en          = 1'b0;
                        gclk_en         = 1'b0;
                        addr_code       = 2'b0;
                        reg_wr_en       = 1'b0;
                        reg_rd_en       = 1'b0;
                        send_ctrl_sig   =  'b0;
                        // next_state
                        next_state      = IDLE;
                    end
        endcase
    end






endmodule
