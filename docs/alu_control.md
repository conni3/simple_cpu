
# Entity: alu_control 
- **File**: alu_control.v

## Diagram
![Diagram](alu_control.svg "Diagram")
## Ports

| Port name | Direction | Type        | Description |
| --------- | --------- | ----------- | ----------- |
| ALUOp     | input     | wire [1:0]  | High-level ALU operation code |
| funct3    | input     | wire [2:0]  | Instruction `funct3` field |
| funct7_5  | input     | wire        | Bit 5 of instruction `funct7` field |
| ALUCtrl   | output    | wire [3:0]  | 4‑bit control signal selecting ALU operation |

## Processes
- unnamed: ( @(*) )
  - **Type:** always

## Behavior
Maps `ALUOp`, `funct3`, and `funct7_5` to a 4‑bit `ALUCtrl` code that drives the ALU operation.
