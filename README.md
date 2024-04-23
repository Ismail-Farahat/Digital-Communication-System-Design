# Digital-Communication-System-Design
## Project Description: 
* System receives serial data across UART-RX unit, this data contains frames that represent command to the system, the control unit receives the data and based on the command type, control unit works on directing the data to reg file or ALU to perform write, read, mathematical and logical operations. Then control unit sends the results to the UART-RX to send its data frames back.
* I designed the system from scratch using Verilog in both design and basic verification, simulated and debugged my design on VIVADO software and Synopsys tools.
## System Blocks: 
* UART (TX-RX)
* ALU, unsigned multiplier, unsigned divisor
* Reg file
* Integer clock divider
* Clock gating
* Synchronizers (reset-data-bit)
* Control unit using mealy FSM.
## Testbanch
* UART testbech
* System Top Module testbench
