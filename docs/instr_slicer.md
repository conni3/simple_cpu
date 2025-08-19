
# Entity: instr_slicer 
- **File**: instr_slicer.v

## Diagram
![Diagram](instr_slicer.svg "Diagram")
## Ports

| Port name | Direction | Type        | Description |
| --------- | --------- | ----------- | ----------- |
| instr     | input     | wire [31:0] |             |
| opcode    | output    | wire [6:0]  |             |
| rd        | output    | wire [4:0]  |             |
| funct3    | output    | wire [2:0]  |             |
| rs1       | output    | wire [4:0]  |             |
| rs2       | output    | wire [4:0]  |             |
| funct7    | output    | wire [6:0]  |             |
| shamt     | output    | wire [ 4:0] |             |
| csr       | output    | wire [19:0] |             |
