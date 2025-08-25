
# Entity: decoder 
- **File**: decoder.v

## Diagram
![Diagram](../images/docs/decoder.svg "Diagram")
## Generics

| Generic name | Type | Value | Description |
| ------------ | ---- | ----- | ----------- |
| DATA_WIDTH   | int  | 32    | Width of instruction word |

## Ports

| Port name | Direction | Type                  | Description |
| --------- | --------- | --------------------- | ----------- |
| instr     | input     | wire [DATA_WIDTH-1:0] | Instruction to decode |
| ALUreg    | output    | wire                  | High for R-type ALU ops |
| regWrite  | output    | wire                  | Indicates destination register should be written |
| JAL       | output    | wire                  | JAL instruction flag |
| JALR      | output    | wire                  | JALR instruction flag |
| Branch    | output    | wire                  | Branch instruction flag |
| LUI       | output    | wire                  | LUI instruction flag |
| AUIPC     | output    | wire                  | AUIPC instruction flag |
| ALUimm    | output    | wire                  | High for I-type ALU ops |
| Load      | output    | wire                  | Load instruction flag |
| Store     | output    | wire                  | Store instruction flag |
| SYSTEM    | output    | wire                  | System/CSR instruction flag |

## Signals

| Name                | Type       | Description |
| ------------------- | ---------- | ----------- |
| opcode = instr[6:0] | wire [6:0] | Opcode field extracted from instruction |

## Behavior
Decodes the 32‑bit instruction opcode to classify instruction types and assert control flags.
