
# Entity: instr_slicer 
- **File**: instr_slicer.v

## Diagram
![Diagram](../images/docs/instr_slicer.svg "Diagram")

## Schematic
![Schematic](../images/schematics/instr_slicer.svg "Schematic")
## Ports

| Port name | Direction | Type        | Description |
| --------- | --------- | ----------- | ----------- |
| instr     | input     | wire [31:0] | 32-bit instruction word |
| opcode    | output    | wire [6:0]  | Bits 6–0: opcode |
| rd        | output    | wire [4:0]  | Bits 11–7: destination register |
| funct3    | output    | wire [2:0]  | Bits 14–12: `funct3` field |
| rs1       | output    | wire [4:0]  | Bits 19–15: source register 1 |
| rs2       | output    | wire [4:0]  | Bits 24–20: source register 2 |
| funct7    | output    | wire [6:0]  | Bits 31–25: `funct7` field |
| shamt     | output    | wire [4:0]  | Shift amount for immediate shifts |
| csr       | output    | wire [19:0] | CSR address for SYSTEM instructions |

## Behavior
Breaks a 32‑bit instruction into common fields used by the decoder and control logic.
