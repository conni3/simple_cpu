
# Entity: instr_mem 
- **File**: instr_mem.v

## Diagram
![Diagram](instr_mem.svg "Diagram")
## Ports

| Port name | Direction | Type        | Description |
| --------- | --------- | ----------- | ----------- |
| addr      | input     | wire [10:0] | Word address of instruction |
| instr     | output    | wire [31:0] | Instruction fetched from memory |

## Signals

| Name             | Type       | Description |
| ---------------- | ---------- | ----------- |
| mem[0:(1<<11)-1] | reg [31:0] | 2^11 entries of 32-bit instruction memory |

## Processes
- unnamed: ( @(*) )
  - **Type:** always

## Behavior
Provides combinational read access to the instruction memory initialized from a hex file.
