
# Entity: reg_file 
- **File**: regfile.v

## Diagram
![Diagram](reg_file.svg "Diagram")
## Ports

| Port name  | Direction | Type        | Description |
| ---------- | --------- | ----------- | ----------- |
| clk        | input     | wire        | Clock input |
| reset      | input     | wire        | Synchronous reset |
| regwrite   | input     | wire        | Register write enable |
| read_reg1  | input     | wire [4:0]  | Address of source register 1 |
| read_reg2  | input     | wire [4:0]  | Address of source register 2 |
| write_reg  | input     | wire [4:0]  | Destination register address |
| write_data | input     | wire [31:0] | Data to write to `write_reg` |
| read_data1 | output    | wire [31:0] | Data from register `read_reg1` |
| read_data2 | output    | wire [31:0] | Data from register `read_reg2` |

## Signals

| Name       | Type       | Description |
| ---------- | ---------- | ----------- |
| regs[31:0] | reg [31:0] | Array of 32 general-purpose registers |
| i          | integer    | Loop variable for reset |

## Processes
- unnamed: ( @(posedge clk) )
  - **Type:** always

## Behavior
Implements a 32×32‑bit register file with two asynchronous read ports and one synchronous write port; register x0 is hard-wired to zero.
