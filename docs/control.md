
# Entity: control 
- **File**: control.v

## Diagram
![Diagram](control.svg "Diagram")
## Generics

| Generic name | Type | Value | Description |
| ------------ | ---- | ----- | ----------- |
| DATA_WIDTH   |      | 32    |             |

## Ports

| Port name | Direction | Type                  | Description |
| --------- | --------- | --------------------- | ----------- |
| instr     | input     | wire [DATA_WIDTH-1:0] |             |
| ALUreg    | input     | wire                  |             |
| ALUimm    | input     | wire                  |             |
| Branch    | input     | wire                  |             |
| JAL       | input     | wire                  |             |
| JALR      | input     | wire                  |             |
| LUI       | input     | wire                  |             |
| AUIPC     | input     | wire                  |             |
| Load      | input     | wire                  |             |
| Store     | input     | wire                  |             |
| SYSTEM    | input     | wire                  |             |
| MemRead   | output    |                       |             |
| MemWrite  | output    |                       |             |
| MemtoReg  | output    |                       |             |
| ALUSrc    | output    |                       |             |
| BranchSig | output    |                       |             |
| Jump      | output    |                       |             |
| ALUOp     | output    | [           1:0]      |             |
| ImmSrc    | output    | [           2:0]      |             |

## Processes
- unnamed: ( @(*) )
  - **Type:** always
