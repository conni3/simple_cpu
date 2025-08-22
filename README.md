# Project Usage Guide

## 0) Prerequisites

* **Icarus Verilog** (`iverilog`, `vvp`)
* **GTKWave** (`gtkwave`) for waveforms
* (Optional) **Vivado XSIM** (`xvlog`, `xelab`, `xsim`)

  * Default Vivado settings file: `VIVADO_SETTINGS=/opt/Xilinx/Vivado/2025.1/2025.1/Vivado/settings64.sh`
  * Override if different:

    ```bash
    make vivado comp=foo VIVADO_VERSION=2024.2 VIVADO_SETTINGS=/path/to/settings64.sh
    ```
* (Optional) **Schematic rendering tools**: `yosys`, `jq`, `netlistsvg`

### Project Layout

```
include/        // headers (e.g., defines.vh)
src/leaf/       // leaf RTL modules
src/glue/       // glue/adapter modules
src/top/        // top-level wrappers
tb/             // testbenches named <module>_tb.v
images/         // rendered schematics (.svg)
.build/         // compiled outputs (auto-created)
waves/          // VCDs (auto-created)
```

> Testbenches must follow the format `tb/<name>_tb.v`. The Makefile auto-detects them.

---

## 1) Quick Start (Icarus)

```bash
make           # same as: make test
```

* Lints, compiles, and runs all `tb/*_tb.v` files.
* Generates VCDs in `waves/<name>.vcd` if `$dumpfile("dump.vcd")` is present in the testbench.

---

## 2) Run a Single Testbench

Pick the `comp` name (the prefix before `_tb.v`).

**Lint**

```bash
make check comp=alu_control
```

**Compile**

```bash
make build comp=alu_control
# Output: .build/alu_control.vvp
```

**Run**

```bash
make run comp=alu_control
# or: make test comp=alu_control
```

**Open Waveform**

```bash
make wave comp=alu_control
# Opens waves/alu_control.vcd in GTKWave
```

---

## 3) Vivado XSIM (Optional)

Run a single testbench:

```bash
make vivado comp=alu_control
```

Run all testbenches:

```bash
make vivado-all
```

Override version or settings:

```bash
make vivado comp=alu_control VIVADO_SETTINGS=/path/to/settings64.sh
make vivado comp=alu_control VIVADO_VERSION=2024.2 VIVADO_SETTINGS=/opt/Xilinx/Vivado/2024.2/.../settings64.sh
```

---

## 4) Generate Schematics

List modules:

```bash
make mods
```

Render **all modules**:

```bash
make schem
```

Render a **specific top module**:

```bash
make schem-top comp=cpu
# Outputs: images/cpu.svg
```

Clean schematic artifacts:

```bash
make schem-clean
```

---

## 5) Clean Outputs

```bash
make clean
```

Removes `.build/`, `waves/`, simulation artifacts, and Vivado XSIM leftovers.

---

## 6) Tips & Conventions

* The `include/` directory is already passed with `-I include`, so `` `include "defines.vh"`` works directly.
* Each testbench should generate a VCD:

  ```verilog
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, <top_of_tb_or_dut>);
  end
  ```

  The Makefile renames it to `waves/<tbname>.vcd`.
* To add a new testbench `tb/<name>_tb.v`, no Makefile edits are needed.

  * Run all: `make`
  * Run one: `make test comp=<name>`
* If `schem-top` fails with “No such command,” ensure `yosys`, `jq`, and `netlistsvg` are installed and in `PATH`.
* For Vivado errors, check `settings64.sh` and override `VIVADO_SETTINGS` if needed.

---

## 7) Common Problems

**Q: My VCD is missing.**
A: Ensure the testbench has `$dumpfile("dump.vcd")` and `$dumpvars(...)`. Without them, no waveform is produced.

**Q: XSIM says snapshot not found.**
A: The flow is:

1. `xvlog` (compile)
2. `xelab -snapshot <name>_sim work.<name>_tb` (elaboration)
3. `xsim <name>_sim --runall` (simulation)

Check that `comp=<name>` matches the testbench prefix and that `xvlog` completed successfully.

**Q: `@* is sensitive to all words in array` warning in Icarus.**
A: Harmless. It occurs when reading from a `reg [] mem []` in a combinational block. Safe to ignore for simple simulations.

---

# Signal Glossary

| Category               | Signals                                                                                                                |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Instruction/fields** | `instr`, `opcode`, `funct3`, `funct7`, `shamt`, `csr`                                                                  |
| **Regs**               | `rs1`, `rs2`, `rd`, `rs1_data`, `rs2_data`, `rd_wdata`, `reg_write`                                                    |
| **ALU**                | `alu_op` (2b), `alu_ctrl` (4b), `alu_result`, `alu_zero`                                                               |
| **Immediates**         | `imm_sel` (3b), `imm_out`                                                                                              |
| **PC/flow**            | `pc_current`, `pc_next`, `pc_plus4`, `branch_taken`, `is_branch`, `is_jal`, `is_jalr`                                  |
| **Memory**             | `mem_read`, `mem_write`, `addr`, `wdata`, `rdata`                                                                      |
| **Writeback**          | `wb_sel` (2b)                                                                                                          |
| **Instr. type flags**  | `is_alu_reg`, `is_alu_imm`, `is_branch`, `is_jal`, `is_jalr`, `is_lui`, `is_auipc`, `is_load`, `is_store`, `is_system` |

---

# Module Reference

| Module            | Inputs                                                                                                                          | Outputs                                                                                                                                                                                                                                                     |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **adder**         | `a`, `b`                                                                                                                        | `sum`                                                                                                                                                                                                                                                       |
| **alu**           | `op_a`, `op_b`, `alu_ctrl`                                                                                                      | `alu_result`, `alu_zero`                                                                                                                                                                                                                                    |
| **alu\_control**  | `alu_op`, `funct3`, `funct7_5`                                                                                                  | `alu_ctrl`                                                                                                                                                                                                                                                  |
| **branch\_comp**  | `op1`, `op2`, `funct3`                                                                                                          | `branch_taken`                                                                                                                                                                                                                                              |
| **control**       | `instr`, `is_alu_reg`, `is_alu_imm`, `is_branch`, `is_jal`, `is_jalr`, `is_lui`, `is_auipc`, `is_load`, `is_store`, `is_system` | `mem_read`, `mem_write`, `wb_sel`, `alu_src`, `branch_sig`, `jump`, `alu_op`, `imm_sel`                                                                                                                                                                     |
| **data\_mem**     | `clk`, `mem_write`, `mem_read`, `addr`, `wdata`                                                                                 | `rdata`                                                                                                                                                                                                                                                     |
| **decoder**       | `instr`                                                                                                                         | `is_alu_reg`, `reg_write`, `is_jal`, `is_jalr`, `is_branch`, `is_lui`, `is_auipc`, `is_alu_imm`, `is_load`, `is_store`, `is_system`                                                                                                                         |
| **decoder\_glue** | `instr`                                                                                                                         | `rd`, `rs1`, `rs2`, `imm_out`, `reg_write`, `mem_read`, `mem_write`, `alu_src`, `branch_sig`, `jump`, `alu_op`, `imm_sel`, `wb_sel`, `is_jal`, `is_jalr`, `is_branch`, `is_lui`, `is_auipc`, `is_alu_reg`, `is_alu_imm`, `is_load`, `is_store`, `is_system` |
| **imm\_gen**      | `instr`, `imm_sel`                                                                                                              | `imm_out`                                                                                                                                                                                                                                                   |
| **instr\_mem**    | `addr`                                                                                                                          | `instr`                                                                                                                                                                                                                                                     |
| **instr\_slicer** | `instr`                                                                                                                         | `opcode`, `rd`, `funct3`, `rs1`, `rs2`, `funct7`, `shamt`, `csr`                                                                                                                                                                                            |
| **next\_pc**      | `pc_current`, `imm_out`, `rs1_data`, `is_branch`, `is_jal`, `is_jalr`, `branch_taken`                                           | `pc_next`                                                                                                                                                                                                                                                   |
| **regfile**       | `clk`, `reset`, `reg_write`, `rs1`, `rs2`, `rd`, `rd_wdata`                                                                     | `rs1_data`, `rs2_data`                                                                                                                                                                                                                                      |
| **wb\_mux**       | `alu_result`, `rdata`, `pc_plus4`, `wb_sel`, `reg_write_in`, `kill_wb`, `rd_in`                                                 | `rd_wdata`, `reg_write_out`, `rd_out`                                                                                                                                                                                                                       |
