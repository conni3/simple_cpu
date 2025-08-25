
# Entity: imm_gen 
- **File**: imm_gen.v

## Diagram
![Diagram](imm_gen.svg "Diagram")
## Ports

| Port name | Direction | Type        | Description |
| --------- | --------- | ----------- | ----------- |
| instr     | input     | wire [31:0] | Instruction providing immediate fields |
| imm_sel   | input     | wire [2:0]  | Immediate type selector |
| imm_out   | output    | wire [31:0] | Sign-extended immediate result |

## Signals

| Name                                                                              | Type        | Description |
| --------------------------------------------------------------------------------- | ----------- | ----------- |
| i_imm = {{20{instr[31]}}, instr[31:20]}                                           | wire [31:0] | I-type immediate |
| s_imm = {{20{instr[31]}}, instr[31:25], instr[11:7]}                              | wire [31:0] | S-type immediate |
| b_imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}   | wire [31:0] | B-type branch offset |
| u_imm                                                                             | wire [31:0] | Upper-immediate (U-type) |
| j_imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0} | wire [31:0] | Jump immediate (J-type) |

## Processes
- unnamed: ( @(*) )
  - **Type:** always

## Behavior
Generates sign-extended immediates in I, S, B, U, or J formats based on `imm_sel`.
