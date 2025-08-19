
# Entity: alu_control 
- **File**: alu_control.v

## Diagram
![Diagram](alu_control.svg "Diagram")
## Ports

| Port name | Direction | Type       | Description |
| --------- | --------- | ---------- | ----------- |
| ALUOp     | input     | wire [1:0] |             |
| funct3    | input     | wire [2:0] |             |
| funct7_5  | input     | wire       |             |
| ALUCtrl   | output    | [3:0]      |             |

## Processes
- unnamed: ( @(*) )
  - **Type:** always
