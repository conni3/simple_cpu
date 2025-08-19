
# Entity: data_mem 
- **File**: data_mem.v

## Diagram
![Diagram](data_mem.svg "Diagram")
## Ports

| Port name  | Direction | Type        | Description |
| ---------- | --------- | ----------- | ----------- |
| clk        | input     | wire        |             |
| we         | input     | wire        |             |
| re         | input     | wire        |             |
| addr       | input     | wire [10:0] |             |
| write_data | input     | wire [31:0] |             |
| read_data  | output    | [31:0]      |             |

## Signals

| Name             | Type       | Description |
| ---------------- | ---------- | ----------- |
| mem[(1<<11)-1:0] | reg [31:0] |             |

## Processes
- unnamed: ( @(posedge clk) )
  - **Type:** always
