# Project Overview

- Modular, single-cycle RV32I CPU core in Verilog
- Reusable blocks, automated Makefile flow, testbenches
- Goals: clarity for learning and easy extensibility

# Objectives

| Objective                | Details                                          |
| ------------------------ | ------------------------------------------------ |
| Implement RV32I subset   | ALU, control, memory, branch & jump support      |
| Deliver reusable modules | Decode, execute, memory access, write-back       |
| Automate workflow        | `make` targets for lint, sim, schematics, Vivado |

# Simulation & Validation

| Program          | Focus             |
| ---------------- | ----------------- |
| `add`            | ALU arithmetic    |
| `store` / `load` | Memory interface  |
| `jump`           | PC control        |
| `branches`       | Branch comparator |

Cross-checked with RARS/QEMU.

# Waveforms

![CPU program waveform](../images/waveforms/cpu.png)

## 1) 0x01000313

- `ADDI x6, x0, 16`  
- `imm_out=0x10`, `rd=06`, `rs1=00`, `alu_ctrl=ADD`  
- `debug_alu=0x10` equals `x0 + 16`  
- `reg_write=1` writes x6

## 2) 0xDEADC3B7

- `LUI x7, 0xDEADC`  
- `rd=07`, `imm_out=0xDEADC000`  
- `debug_alu=0xDEADC000`  
- `reg_write=1`

## 3) 0xEEF38393

- `ADDI x7, x7, -273` (`0xFFFFFEEF`)  
- `rs1=07`, `rd=07`, `imm_out=0xFFFFFEEF`  
- `debug_alu=0xDEADC000 + 0xFFFFFEEF` → expected `0xDEADC0..`  
- Matches spec

## 4) 0x04702023

- `SW x7, 72(x0)`  
- `mem_write=1`, `rs2=07`, base `x0`, `imm=0x48`  
- Control signals correct

## 5) 0x0000006F

- `JAL x0, 0`  
- PC updates, `wb_sel=01`, `op1_sel` set for jump  
- `reg_write=0` since `rd=x0`

# Instruction Coverage

| Category                       | Instructions                                         |
| ------------------------------ | ---------------------------------------------------- |
| Arithmetic & logic (reg)       | add, sub, and, or, xor, sll, srl, sra, slt, sltu     |
| Arithmetic & logic (imm)       | addi, xori, ori, andi, slli, srli, srai, slti, sltiu |
| Memory access                  | lw, sw                                               |
| Branches                       | beq, bne, blt, bltu, bge, bgeu                       |
| Jumps                          | jal, jalr                                            |
| Upper immediates & PC-relative | lui, auipc                                           |

# Architecture Snapshot

- Controller decodes and generates signals
- Datapath executes via regfile, ALU, memories
- Branch comparator and PC logic drive control flow

![CPU Block Diagram](../images/vivado_elaborated_design/cpu.png)

# Core Modules

| Module         | Responsibility                             |
| -------------- | ------------------------------------------ |
| **controller** | Decode, generate control, ALU op selection |
| **datapath**   | Regfile, ALU, memories, PC & branch logic  |
| **cpu**        | Top-level wrapper with debug probes        |

# Controller

- Slices fields from instruction (opcode, funct3, funct7, rs/rd)
- Delegates to **decoder_glue**:
  - **decoder**: classify instruction, set `reg_write`
  - **control**: map to datapath signals (`mem_*`, `alu_src`, `wb_sel`)
  - **imm_gen**: sign-extend immediates (I/S/B/U/J)
- Feeds `alu_op`, `funct3`, `funct7[5]` into **alu_control**
- Emits all signals for datapath

![Controller Diagram](../images/vivado_elaborated_design/controller.png)

# Datapath

- Executes full instruction cycle
- **Control flow**: `branch_comp` + `next_pc` + PC register
- **Regfile**: 32×32, sync write, combinational read
- **Operand select**: `rs1`/PC/zero and `rs2`/imm
- **ALU**: arithmetic/logic ops, result → mem or write-back
- **Memory**: word-addressed instruction/data memories, sync writes
- **Write-back**: mux between ALU result, memory, `pc+4`

![Datapath Diagram](../images/vivado_elaborated_design/datapath.png)

# Supporting Modules

| Module                  | Purpose                                |
| ----------------------- | -------------------------------------- |
| `alu`, `alu_control`    | Arithmetic & logic execution           |
| `branch_comp`           | Branch evaluation                      |
| `regfile`               | 32×32 register file, x0 guard          |
| `instr_mem`, `data_mem` | Program/data storage, `$readmemh` init |
| `next_pc`               | PC update logic                        |
| `imm_gen`               | Immediate extraction                   |
| `mux2`, `mux4`          | Multiplexers                           |
| `pc`                    | Program counter register               |
| `instr_slicer`          | Instruction field utility              |
| `wb_mux`                | Write-back mux                         |

# CPU Validation

| Program        | Tested Instructions                                  | Pass  |
| -------------- | ---------------------------------------------------- | :---: |
| `prog.mem`     | load, store, jal                                     |  yes  |
| `branches.mem` | beq, bne, blt, bltu, bge, bgeu                       |  yes  |
| `r_alu.mem`    | add, sub, and, or, xor, sll, srl, sra, slt, sltu     |  yes  |
| `i_alu.mem`    | addi, xori, ori, andi, slli, srli, srai, slti, sltiu |  yes  |
| `mem_rw.mem`   | lui, sw, lw, add                                     |  yes  |
| `jumps.mem`    | auipc, jal, jalr                                     |  yes  |
| `x0_guard.mem` | addi(x0), sub(x0), beq                               |  yes  |

# RTL Testing

| Module       | Scope                        | Tests |
| ------------ | ---------------------------- | ----: |
| adder        | Overflow, negatives          |     4 |
| alu_control  | ALUOp decoding               |    22 |
| alu          | ADD, SUB, logic, shifts, cmp |    11 |
| branch_comp  | BEQ/BNE/BLT/BGE/BLTU/BGEU    |    13 |
| controller   | Flow checks                  |    65 |
| control      | R/I ops, mem, branch, jumps  |    17 |
| cpu          | Small program                |     2 |
| data_mem     | Init read                    |     1 |
| datapath     | ALU, mem, branch, jumps      |    17 |
| decoder_glue | Glue interface               |   N/A |
| decoder      | R/I/S/B/U/J decode           |     9 |
| imm_gen      | Immediate formats            |    11 |
| instr_mem    | Program read                 |     3 |
| instr_slicer | Field slices + random tests  |   210 |
| next_pc      | PC updates                   |     7 |
| pc           | Reset, increment, jump       |     4 |
| regfile      | Reset, writes, x0 check      |   154 |
| wb_mux       | ALU/MEM/PC+4 paths           |     8 |

# Key Results

| Metric              | Value                             | Source               |
| ------------------- | --------------------------------- | -------------------- |
| Slice LUTs          | 2,439                             | `utilization.rpt`    |
| Slice Registers     | 1,056                             | `utilization.rpt`    |
| Max clock frequency | N/A (no timing constraints)       | `timing_summary.rpt` |
| On-chip power       | 3.618 W (dyn 3.453, static 0.165) | `power.rpt`          |

# Challenges & Mitigations

| Challenge                | Mitigation                 |
| ------------------------ | -------------------------- |
| Branch waveform misalign | Added delay/register       |
| Limited RV32I subset     | Plan incremental expansion |
| Higher LUT use           | Accepted for teaching      |

# Future Work

- Extend ISA: RV32M, CSR, pipelining
- Broaden automated test coverage
- Add privileged ISA support
- Benchmark against other cores

# References

1. RISC-V ISA Specification, Volume I
2. Icarus Verilog and GTKWave documentation
3. Xilinx Vivado user guides
4. yosys and netlistsvg documentation
5. Patterson & Hennessy, *Computer Organization and Design RISC-V Edition*

# Contact & Handover

- Repository includes docs, schematics, waveforms
- Contact maintainers for onboarding
- End of handover
