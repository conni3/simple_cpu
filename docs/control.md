# Entity: control
- **File**: control.v

## Diagram
![Diagram](../images/docs/control.svg "Diagram")

## Schematic
![Schematic](../images/schematics/control.svg "Schematic")
## Generics

| Generic name | Type | Value | Description |
| ------------ | ---- | ----- | ----------- |
| DATA_WIDTH   | int  | 32    | Width of instruction word and immediates |

## Ports

| Port name | Direction | Type                  | Description |
| --------- | --------- | --------------------- | ----------- |
| instr     | input     | wire [DATA_WIDTH-1:0] | 32-bit instruction word |
| is_alu_reg| input     | wire                  | High for R-type ALU ops |
| is_alu_imm| input     | wire                  | High for I-type ALU ops |
| is_branch | input     | wire                  | Indicates branch instruction |
| is_jal    | input     | wire                  | Indicates JAL instruction |
| is_jalr   | input     | wire                  | Indicates JALR instruction |
| is_lui    | input     | wire                  | Indicates LUI instruction |
| is_auipc  | input     | wire                  | Indicates AUIPC instruction |
| is_load   | input     | wire                  | Load instruction flag |
| is_store  | input     | wire                  | Store instruction flag |
| is_system | input     | wire                  | System/CSR instruction flag |
| mem_read  | output    | wire                  | Assert to read data memory |
| mem_write | output    | wire                  | Assert to write data memory |
| alu_src   | output    | wire                  | Selects ALU operand B: 0=rs2, 1=imm |
| branch_sig| output    | wire                  | High for branch evaluation |
| jump      | output    | wire                  | High when PC should jump |
| alu_op    | output    | wire [1:0]            | ALU operation class |
| imm_sel   | output    | wire [2:0]            | Immediate type selector |
| wb_sel    | output    | wire [1:0]            | Write-back source selector |
| op1_sel   | output    | wire [1:0]            | First ALU operand source selector |

## Behavior
Generates control signals based on decoded instruction type flags, selecting ALU operation, immediate form, operand sources, memory access, and write-back routing.

