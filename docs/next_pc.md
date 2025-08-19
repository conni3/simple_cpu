
# Entity: next_pc 
- **File**: next_pc.v

## Diagram
![Diagram](next_pc.svg "Diagram")
## Ports

| Port name    | Direction | Type                   | Description |
| ------------ | --------- | ---------------------- | ----------- |
| current_pc   | input     | wire [`DATA_WIDTH-1:0] |             |
| imm_data     | input     | wire [`DATA_WIDTH-1:0] |             |
| rs1_data     | input     | wire [`DATA_WIDTH-1:0] |             |
| is_branch    | input     | wire                   |             |
| is_jal       | input     | wire                   |             |
| is_jalr      | input     | wire                   |             |
| branch_taken | input     | wire                   |             |
| next_pc      | output    | wire [`DATA_WIDTH-1:0] |             |

## Signals

| Name                                                              | Type                   | Description |
| ----------------------------------------------------------------- | ---------------------- | ----------- |
| pc_plus4 = current_pc + 4                                         | wire [`DATA_WIDTH-1:0] |             |
| branch_jal_pc = current_pc + imm_data                             | wire [`DATA_WIDTH-1:0] |             |
| jalr_raw = rs1_data + imm_data                                    | wire [`DATA_WIDTH-1:0] |             |
| jalr_aligned                                                      | wire [`DATA_WIDTH-1:0] |             |
| misalign_pc = (current_pc[1:0] != 2'b00) || next_pc[1:0] != 2'b00 | wire                   |             |

## Processes
- unnamed: ( @(*) )
  - **Type:** always
