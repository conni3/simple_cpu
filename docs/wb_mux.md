
# Entity: wb_mux 
- **File**: wb_mux.v

## Diagram
![Diagram](../images/docs/wb_mux.svg "Diagram")
## Ports

| Port name    | Direction | Type                   | Description |
| ------------ | --------- | ---------------------- | ----------- |
| alu_result   | input     | wire [`DATA_WIDTH-1:0] | ALU result value |
| load_rdata   | input     | wire [`DATA_WIDTH-1:0] | Data read from memory |
| pc_plus4     | input     | wire [`DATA_WIDTH-1:0] | PC incremented by 4 |
| wb_sel       | input     | wire [1:0]             | Selects write-back source |
| regwrite_in  | input     | wire                   | Control-signal write enable |
| kill_wb      | input     | wire                   | Suppress write-back on exceptions |
| rd_in        | input     | wire [4:0]             | Destination register index |
| rd_wdata     | output    | wire [`DATA_WIDTH-1:0] | Data forwarded for register write |
| regwrite_out | output    | wire                   | Gated register write enable |
| rd_out       | output    | wire [4:0]             | Forwarded register index |

## Processes
- unnamed: ( @* )
  - **Type:** always

## Behavior
Selects the value written back to the register file based on `wb_sel` and gates writes with `kill_wb` and zero‑register checks.
