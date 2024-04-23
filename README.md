# Digital-Communication-System-Design
## Project Description: 
* System receives serial data across UART-RX unit, this data contains frames that represent command to the system, the control unit receives the data and based on the command type, control unit works on directing the data to reg file or ALU to perform write, read, mathematical and logical operations. Then control unit sends the results to the UART-RX to send its data frames back.
* I designed the system from scratch using Verilog in both design and basic verification, simulated and debugged my design on VIVADO software and Synopsys tools.

## System Hierarchy
![SystemHierarchy](https://github.com/Ismail-Farahat/Digital-Communication-System-Design/assets/68667962/0e212619-f856-4b23-9769-17650e6b3dee)

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

## Waveform
* Sending two commands to the system that receiving them through UART-RX and then transmiting the result through the UART-TX
* First Command: divide two numbers ('h08 and 'h02) **[Command: 'CC_08_02_03]**
* Second Command: Multiply two numbers ('h04 and 'h03) **[command: 'CC_04_03_02]**
![waveform](https://github.com/Ismail-Farahat/Digital-Communication-System-Design/assets/68667962/0aea12d1-afb0-4fdc-8afa-b1041364328b)
