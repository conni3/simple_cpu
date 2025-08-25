
# Entity: alu 
- **File**: alu.v

## Diagram
![Diagram](../images/docs/alu.svg "Diagram")
## Ports

| Port name   | Direction | Type        | Description |
| ----------- | --------- | ----------- | ----------- |
| operand_a   | input     | wire [31:0] | First operand |
| operand_b   | input     | wire [31:0] | Second operand |
| alu_control | input     | wire [3:0]  | 4‑bit operation select code |
| alu_result  | output    | wire [31:0] | Result of selected operation |
| zero        | output    | wire        | High when `alu_result` equals zero |

## Processes
- unnamed: ( @(*) )
  - **Type:** always

## Behavior
Executes arithmetic and logic operations based on `alu_control`; sets `zero` when `alu_result` is `0`.
