
# Entity: alu 
- **File**: alu.v

## Diagram
![Diagram](alu.svg "Diagram")
## Ports

| Port name   | Direction | Type        | Description |
| ----------- | --------- | ----------- | ----------- |
| operand_a   | input     | wire [31:0] |             |
| operand_b   | input     | wire [31:0] |             |
| alu_control | input     | wire [ 3:0] |             |
| alu_result  | output    | [31:0]      |             |
| zero        | output    | wire        |             |

## Processes
- unnamed: ( @(*) )
  - **Type:** always
