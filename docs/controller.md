
# Entity: controller 
- **File**: controller.v

## Diagram
![Diagram](../images/docs/controller.svg "Diagram")

## Schematic
![Schematic](../images/schematics/controller.svg "Schematic")
## Ports

| Port name | Direction | Type        | Description |
| --------- | --------- | ----------- | ----------- |
| instr     | input     | wire [31:0] | 32‑bit instruction word |
| opcode    | output    | wire [6:0]  | Operation code (bits 6–0) |
| rd        | output    | wire [4:0]  | Destination register index |
| funct3    | output    | wire [2:0]  | Instruction `funct3` field |
| rs1       | output    | wire [4:0]  | Source register 1 index |
| rs2       | output    | wire [4:0]  | Source register 2 index |
| funct7    | output    | wire [6:0]  | Instruction `funct7` field |
| csr       | output    | wire [19:0] | CSR address field |
| alu_ctrl  | output    | wire [3:0]  | ALU control code |
| imm_out   | output    | wire [31:0] | Sign‑extended immediate |
| reg_write | output    | wire        | Register write enable |
| mem_read  | output    | wire        | Data memory read enable |
| mem_write | output    | wire        | Data memory write enable |
| alu_src   | output    | wire        | ALU operand B select: 0=rs2, 1=imm |
| op1_sel   | output    | wire [1:0]  | ALU operand A source |
| wb_sel    | output    | wire [1:0]  | Write-back source selector |
| is_branch | output    | wire        | Indicates branch instruction |
| is_jal    | output    | wire        | Indicates JAL instruction |
| is_jalr   | output    | wire        | Indicates JALR instruction |

## Signals

| Name    | Type       | Description |
| ------- | ---------- | ----------- |
| alu_op  | wire [1:0] |             |
| imm_sel | wire [2:0] |             |
| f       | wire       |             |

## Instantiations

- u_decoder_glue: decoder_glue
- u_alu_control: alu_control

## Behavior
Slices fields from `instr`, decodes instruction type, generates immediate and ALU control, and produces control signals for the datapath.
