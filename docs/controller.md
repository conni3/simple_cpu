
# Entity: controller 
- **File**: controller.v

## Diagram
![Diagram](controller.svg "Diagram")
## Ports

| Port name | Direction | Type        | Description |
| --------- | --------- | ----------- | ----------- |
| instr     | input     | wire [31:0] |             |
| opcode    | output    | wire [ 6:0] |             |
| rd        | output    | wire [ 4:0] |             |
| funct3    | output    | wire [ 2:0] |             |
| rs1       | output    | wire [ 4:0] |             |
| rs2       | output    | wire [ 4:0] |             |
| funct7    | output    | wire [ 6:0] |             |
| csr       | output    | wire [19:0] |             |
| alu_ctrl  | output    | wire [ 3:0] |             |
| imm_out   | output    | wire [31:0] |             |
| reg_write | output    | wire        |             |
| mem_read  | output    | wire        |             |
| mem_write | output    | wire        |             |
| alu_src   | output    | wire        |             |
| op1_sel   | output    | wire [ 1:0] |             |
| wb_sel    | output    | wire [ 1:0] |             |
| is_branch | output    | wire        |             |
| is_jal    | output    | wire        |             |
| is_jalr   | output    | wire        |             |

## Signals

| Name    | Type       | Description |
| ------- | ---------- | ----------- |
| alu_op  | wire [1:0] |             |
| imm_sel | wire [2:0] |             |
| f       | wire       |             |

## Instantiations

- u_decoder_glue: decoder_glue
- u_alu_control: alu_control
