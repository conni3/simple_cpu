
# Entity: wb_mux 
- **File**: wb_mux.v

## Diagram
![Diagram](wb_mux.svg "Diagram")
## Ports

| Port name    | Direction | Type                   | Description |
| ------------ | --------- | ---------------------- | ----------- |
| alu_result   | input     | wire [`DATA_WIDTH-1:0] |             |
| load_rdata   | input     | wire [`DATA_WIDTH-1:0] |             |
| pc_plus4     | input     | wire [`DATA_WIDTH-1:0] |             |
| wb_sel       | input     | wire [            1:0] |             |
| regwrite_in  | input     | wire                   |             |
| kill_wb      | input     | wire                   |             |
| rd_in        | input     | wire [            4:0] |             |
| rd_wdata     | output    | [`DATA_WIDTH-1:0]      |             |
| regwrite_out | output    | wire                   |             |
| rd_out       | output    | wire [            4:0] |             |

## Processes
- unnamed: ( @* )
  - **Type:** always
