
# Entity: datapath 
- **File**: datapath.v

## Diagram
![Diagram](datapath.svg "Diagram")
## Generics

| Generic name | Type    | Value               | Description |
| ------------ | ------- | ------------------- | ----------- |
| DATA_WIDTH   | integer | `DATA_WIDTH         |             |
| ADDR_WIDTH   | integer | `ADDR_WIDTH         |             |
| IMEM_FILE    |         | "src/instr_mem.mem" |             |
| DMEM_FILE    |         | "src/data_mem.mem"  |             |

## Ports

| Port name | Direction | Type        | Description |
| --------- | --------- | ----------- | ----------- |
| clk       | input     | wire        |             |
| reset     | input     | wire        |             |
| opcode    | input     | wire [ 6:0] |             |
| rd        | input     | wire [ 4:0] |             |
| funct3    | input     | wire [ 2:0] |             |
| rs1       | input     | wire [ 4:0] |             |
| rs2       | input     | wire [ 4:0] |             |
| funct7    | input     | wire [ 6:0] |             |
| csr       | input     | wire [19:0] |             |
| alu_ctrl  | input     | wire [ 3:0] |             |
| imm_out   | input     | wire [31:0] |             |
| reg_write | input     | wire        |             |
| mem_read  | input     | wire        |             |
| mem_write | input     | wire        |             |
| alu_src   | input     | wire        |             |
| op1_sel   | input     | wire [ 1:0] |             |
| wb_sel    | input     | wire [ 1:0] |             |
| is_branch | input     | wire        |             |
| is_jal    | input     | wire        |             |
| is_jalr   | input     | wire        |             |
| instr     | output    | wire [31:0] |             |

## Signals

| Name                                   | Type                  | Description |
| -------------------------------------- | --------------------- | ----------- |
| branch_taken                           | wire                  |             |
| rs1_data                               | wire [31:0]           |             |
| rs2_data                               | wire [31:0]           |             |
| pc_current                             | wire [31:0]           |             |
| pc_next                                | wire [31:0]           |             |
| pc_plus4                               | wire [31:0]           |             |
| alu_result                             | wire [31:0]           |             |
| alu_zero                               | wire                  |             |
| rdata                                  | wire [31:0]           |             |
| op_a                                   | wire [31:0]           |             |
| op_b                                   | wire [31:0]           |             |
| wb_data                                | wire [31:0]           |             |
| imem_addr = pc_current[ADDR_WIDTH+1:2] | wire [ADDR_WIDTH-1:0] |             |
| dmem_addr = alu_result[ADDR_WIDTH+1:2] | wire [ADDR_WIDTH-1:0] |             |

## Instantiations

- u_branch_comp: branch_comp
- u_next_pc: next_pc
- u_pc: pc
- u_rf: regfile
- u_alu: alu
- u_imem: instr_mem
- u_dmem: data_mem
