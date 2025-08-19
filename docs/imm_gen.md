
# Entity: imm_gen 
- **File**: imm_gen.v

## Diagram
![Diagram](imm_gen.svg "Diagram")
## Ports

| Port name | Direction | Type        | Description |
| --------- | --------- | ----------- | ----------- |
| instr     | input     | wire [31:0] |             |
| imm_sel   | input     | wire [ 2:0] |             |
| imm_out   | output    | [31:0]      |             |

## Signals

| Name                                                                              | Type        | Description |
| --------------------------------------------------------------------------------- | ----------- | ----------- |
| i_imm = {{20{instr[31]}}, instr[31:20]}                                           | wire [31:0] |             |
| s_imm = {{20{instr[31]}}, instr[31:25], instr[11:7]}                              | wire [31:0] |             |
| b_imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}   | wire [31:0] |             |
| u_imm                                                                             | wire [31:0] |             |
| j_imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0} | wire [31:0] |             |

## Processes
- unnamed: ( @(*) )
  - **Type:** always
