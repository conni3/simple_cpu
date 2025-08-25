
# Entity: datapath 
- **File**: datapath.v

## Diagram
![Diagram](../images/docs/datapath.svg "Diagram")
## Generics

| Generic name | Type    | Value               | Description |
| ------------ | ------- | ------------------- | ----------- |
| DATA_WIDTH   | integer | `DATA_WIDTH        | Width of datapath buses |
| ADDR_WIDTH   | integer | `ADDR_WIDTH       | Address width for memories |
| IMEM_FILE    | string  | "src/instr_mem.mem" | Initial contents for instruction memory |
| DMEM_FILE    | string  | "src/data_mem.mem"  | Initial contents for data memory |

## Ports

| Port name | Direction | Type        | Description |
| --------- | --------- | ----------- | ----------- |
| clk       | input     | wire        | System clock |
| reset     | input     | wire        | Asynchronous reset |
| opcode    | input     | wire [6:0]  | Operation code |
| rd        | input     | wire [4:0]  | Destination register |
| funct3    | input     | wire [2:0]  | Instruction `funct3` field |
| rs1       | input     | wire [4:0]  | Source register 1 |
| rs2       | input     | wire [4:0]  | Source register 2 |
| funct7    | input     | wire [6:0]  | Instruction `funct7` field |
| csr       | input     | wire [19:0] | CSR address field |
| alu_ctrl  | input     | wire [3:0]  | ALU control code |
| imm_out   | input     | wire [31:0] | Immediate value |
| reg_write | input     | wire        | Register write enable |
| mem_read  | input     | wire        | Data memory read enable |
| mem_write | input     | wire        | Data memory write enable |
| alu_src   | input     | wire        | ALU operand B select |
| op1_sel   | input     | wire [1:0]  | ALU operand A source |
| wb_sel    | input     | wire [1:0]  | Write-back source selector |
| is_branch | input     | wire        | Branch instruction flag |
| is_jal    | input     | wire        | JAL instruction flag |
| is_jalr   | input     | wire        | JALR instruction flag |
| instr     | output    | wire [31:0] | Current instruction fetch output |

## Signals

| Name                                   | Type                  | Description |
| -------------------------------------- | --------------------- | ----------- |
| branch_taken                           | wire                  | Branch comparison result |
| rs1_data                               | wire [31:0]           | Data from register `rs1` |
| rs2_data                               | wire [31:0]           | Data from register `rs2` |
| pc_current                             | wire [31:0]           | Current program counter |
| pc_next                                | wire [31:0]           | Next program counter |
| pc_plus4                               | wire [31:0]           | `pc_current + 4` |
| alu_result                             | wire [31:0]           | Result from ALU |
| alu_zero                               | wire                  | High when `alu_result` is zero |
| rdata                                  | wire [31:0]           | Data memory read value |
| op_a                                   | wire [31:0]           | ALU operand A |
| op_b                                   | wire [31:0]           | ALU operand B |
| wb_data                                | wire [31:0]           | Value written back to register file |
| imem_addr = pc_current[ADDR_WIDTH+1:2] | wire [ADDR_WIDTH-1:0] | Instruction memory word address |
| dmem_addr = alu_result[ADDR_WIDTH+1:2] | wire [ADDR_WIDTH-1:0] | Data memory word address |

## Instantiations

- u_branch_comp: branch_comp
- u_next_pc: next_pc
- u_pc: pc
- u_rf: regfile
- u_alu: alu
- u_imem: instr_mem
- u_dmem: data_mem

## Behavior
Implements the CPU datapath: fetches instructions, reads registers, executes ALU operations, computes next PC, and interfaces with instruction and data memories.
