
# Entity: cpu 
- **File**: cpu.v

## Diagram
![Diagram](cpu.svg "Diagram")
## Generics

| Generic name | Type    | Value               | Description |
| ------------ | ------- | ------------------- | ----------- |
| DATA_WIDTH   | integer | 32                  |             |
| ADDR_WIDTH   | integer | `ADDR_WIDTH         |             |
| IMEM_FILE    |         | "src/instr_mem.mem" |             |
| DMEM_FILE    |         | "src/data_mem.mem"  |             |

## Ports

| Port name | Direction | Type | Description |
| --------- | --------- | ---- | ----------- |
| clk       | input     | wire |             |
| reset     | input     | wire |             |

## Signals

| Name      | Type        | Description |
| --------- | ----------- | ----------- |
| instr     | wire [31:0] |             |
| opcode    | wire [ 6:0] |             |
| rd        | wire [4:0]  |             |
| rs1       | wire [4:0]  |             |
| rs2       | wire [4:0]  |             |
| funct3    | wire [ 2:0] |             |
| funct7    | wire [ 6:0] |             |
| csr       | wire [19:0] |             |
| alu_ctrl  | wire [ 3:0] |             |
| imm_out   | wire [31:0] |             |
| reg_write | wire        |             |
| mem_read  | wire        |             |
| mem_write | wire        |             |
| alu_src   | wire        |             |
| op1_sel   | wire [1:0]  |             |
| wb_sel    | wire [1:0]  |             |
| is_branch | wire        |             |
| is_jal    | wire        |             |
| is_jalr   | wire        |             |

## Instantiations

- u_controller: controller
- u_datapath: datapath
