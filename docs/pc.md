
# Entity: pc 
- **File**: pc.v

## Diagram
![Diagram](pc.svg "Diagram")
## Ports

| Port name  | Direction | Type        | Description |
| ---------- | --------- | ----------- | ----------- |
| clk        | input     | wire        |             |
| reset      | input     | wire        |             |
| next_pc    | input     | wire [31:0] |             |
| current_pc | output    | [31:0]      |             |

## Processes
- unnamed: ( @(posedge clk or posedge reset) )
  - **Type:** always
