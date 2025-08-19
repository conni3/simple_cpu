
# Entity: reg_file 
- **File**: regfile.v

## Diagram
![Diagram](reg_file.svg "Diagram")
## Ports

| Port name  | Direction | Type        | Description |
| ---------- | --------- | ----------- | ----------- |
| clk        | input     | wire        |             |
| reset      | input     | wire        |             |
| regwrite   | input     | wire        |             |
| read_reg1  | input     | wire [ 4:0] |             |
| read_reg2  | input     | wire [ 4:0] |             |
| write_reg  | input     | wire [ 4:0] |             |
| write_data | input     | wire [31:0] |             |
| read_data1 | output    | wire [31:0] |             |
| read_data2 | output    | wire [31:0] |             |

## Signals

| Name       | Type       | Description |
| ---------- | ---------- | ----------- |
| regs[31:0] | reg [31:0] |             |
| i          | integer    |             |

## Processes
- unnamed: ( @(posedge clk) )
  - **Type:** always
