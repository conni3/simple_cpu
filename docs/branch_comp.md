
# Entity: branch_comp 
- **File**: branch_comp.v

## Diagram
![Diagram](branch_comp.svg "Diagram")
## Ports

| Port name | Direction | Type        | Description |
| --------- | --------- | ----------- | ----------- |
| op1       | input     | wire [31:0] | First comparison operand |
| op2       | input     | wire [31:0] | Second comparison operand |
| funct3    | input     | wire [2:0]  | 3‑bit branch type selector |
| branch    | output    | wire        | 1‑bit result: high when branch condition met |

## Constants

| Name | Type | Value  | Description |
| ---- | ---- | ------ | ----------- |
| BEQ  |      | 3'b000 |             |
| BNE  |      | 3'b001 |             |
| BLT  |      | 3'b100 |             |
| BGE  |      | 3'b101 |             |
| BLTU |      | 3'b110 |             |
| BGEU |      | 3'b111 |             |

## Processes
- unnamed: ( @(*) )
  - **Type:** always

## Behavior
Compares `op1` and `op2` according to `funct3` (e.g., BEQ, BNE) and asserts `branch` when the selected condition is true.
