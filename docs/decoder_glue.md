
# Entity: decoder_glue 
- **File**: decoder_glue.v

## Diagram
![Diagram](../images/docs/decoder_glue.svg "Diagram")
## Generics

| Generic name | Type | Value | Description |
| ------------ | ---- | ----- | ----------- |
| DATA_WIDTH   | int  | 32    | Width of datapath buses |

## Ports

| Port name | Direction | Type        | Description |
| --------- | --------- | ----------- | ----------- |
| instr     | input     | wire [31:0] | Instruction word |
| rd        | output    | wire [4:0]  | Destination register index |
| rs1       | output    | wire [4:0]  | Source register 1 index |
| rs2       | output    | wire [4:0]  | Source register 2 index |
| imm       | output    | wire [31:0] | Generated immediate |
| regWrite  | output    | wire        | Register write enable |
| MemRead   | output    | wire        | Data memory read enable |
| MemWrite  | output    | wire        | Data memory write enable |
| ALUSrc    | output    | wire        | Selects ALU operand B |
| BranchSig | output    | wire        | Branch evaluation flag |
| Jump      | output    | wire        | Jump instruction flag |
| ALUOp     | output    | wire [1:0]  | High-level ALU operation |
| ImmSrc    | output    | wire [2:0]  | Immediate selection code |
| wb_sel    | output    | wire [1:0]  | Write-back source selector |
| JAL       | output    | wire        | JAL instruction flag |
| JALR      | output    | wire        | JALR instruction flag |
| Branch    | output    | wire        | Branch instruction flag |

## Signals

| Name     | Type | Description |
| -------- | ---- | ----------- |
| ALUreg   | wire | R-type ALU indicator |
| ALUimm   | wire | I-type ALU indicator |
| LUI      | wire | LUI instruction flag |
| AUIPC    | wire | AUIPC instruction flag |
| Load     | wire | Load instruction flag |
| Store    | wire | Store instruction flag |
| SYSTEM   | wire | System/CSR instruction flag |
| MemtoReg | wire | Write-back from memory selector |

## Instantiations

- u_dec: decoder
- u_ctl: control
- u_imm: imm_gen

## Behavior
Combines instruction slicing, coarse decoding, control generation, and immediate formation to drive the datapath.
