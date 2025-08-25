
# Entity: next_pc 
- **File**: next_pc.v

## Diagram
![Diagram](next_pc.svg "Diagram")
## Ports

| Port name    | Direction | Type                   | Description |
| ------------ | --------- | ---------------------- | ----------- |
| current_pc   | input     | wire [`DATA_WIDTH-1:0] | Current program counter |
| imm_data     | input     | wire [`DATA_WIDTH-1:0] | Immediate offset or target address |
| rs1_data     | input     | wire [`DATA_WIDTH-1:0] | Base register for JALR |
| is_branch    | input     | wire                   | Branch instruction flag |
| is_jal       | input     | wire                   | JAL instruction flag |
| is_jalr      | input     | wire                   | JALR instruction flag |
| branch_taken | input     | wire                   | Result of branch comparison |
| next_pc      | output    | wire [`DATA_WIDTH-1:0] | Computed next program counter |

## Signals

| Name                                                              | Type                   | Description |
| ----------------------------------------------------------------- | ---------------------- | ----------- |
| pc_plus4 = current_pc + 4                                         | wire [`DATA_WIDTH-1:0] | PC incremented by 4 |
| branch_jal_pc = current_pc + imm_data                             | wire [`DATA_WIDTH-1:0] | Target for branch or JAL |
| jalr_raw = rs1_data + imm_data                                    | wire [`DATA_WIDTH-1:0] | Unaligned JALR target |
| jalr_aligned                                                      | wire [`DATA_WIDTH-1:0] | JALR target with bit 0 cleared |
| misalign_pc = (current_pc[1:0] != 2'b00) || next_pc[1:0] != 2'b00 | wire                   | Detects misaligned instruction addresses |

## Processes
- unnamed: ( @(*) )
  - **Type:** always

## Behavior
Selects the next program counter based on branch or jump signals; aligns JALR targets and flags misaligned addresses.
