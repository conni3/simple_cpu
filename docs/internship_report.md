# RISC-V CPU Design and Simulation – Internship Report

## 1. Introduction  
This project implements a modular, single-cycle RISC-V CPU core written in Verilog. The repository includes reusable building blocks, control logic, a streamlined Makefile-driven flow, and testbenches for simulation.

> **Figure 1:** _Overall CPU Block Diagram_  
> ![CPU Block Diagram Placeholder](path/to/overall_cpu_block_diagram.png)

## 2. Objectives  
- Develop a fully functional single-cycle CPU that executes a subset of the RISC-V ISA.  
- Provide self-contained Verilog modules for instruction decoding, control, execution, memory access, and write-back.  
- Automate linting, simulation, waveform generation, and schematic rendering using a unified `make` workflow that includes both Icarus Verilog and Vivado flows.

## 3. Tools & Environment  
- **Icarus Verilog** for compilation and simulation.  
- **GTKWave** for waveform inspection.  
- **Vivado XSIM** and schematic tools (`yosys`, `jq`, `netlistsvg`) integrated into the default Make targets—these are mandatory components of the build flow.  
- The Makefile workflow lints, builds, runs, and opens waveforms for all `tb/*_tb.v` testbenches, ensuring both Icarus and Vivado simulations are run by default.  
- Project layout separates headers, leaf RTL, glue logic, top wrappers, testbenches, and generated artifacts.

> **Figure 2:** _Vivado Flow Diagram_  
> ![Vivado Flow Placeholder](path/to/vivado_flow_diagram.png)

## 4. System Architecture  

| Layer | Description | Citations |
|-------|-------------|-----------|
| **Top-Level CPU** | Integrates the controller and datapath, wiring instruction fields, control signals, and memory interfaces | |
| **Controller** | Extracts opcode, registers, immediates, and derives control signals via `decoder_glue` and `alu_control` | |
| **Datapath** | Coordinates instruction fetch, register file access, ALU operations, branch logic, memory access, and write-back selection | |
| **Next PC Unit** | Chooses sequential PC or branch/jump targets, aligning JALR addresses and verifying alignment | |
| **Leaf Modules** | ALU supports arithmetic, logical, and shift operations with zero detection; branch comparator evaluates conditional jumps | |
| **Figure 3:** _Controller–Datapath Interaction_  |
| ![Controller–Datapath Interaction Placeholder](path/to/controller_datapath_interaction.png) |

A complete inventory of modules and their interfaces is documented for quick reference.

## 5. Implementation Highlights  
- Parameterizable data and address widths allow experimentation with different memory sizes.  
- Immediate generation, control, and execution paths remain decoupled for clarity and reuse.  
- Memory files (`src/instr_mem.mem`, `src/data_mem.mem`) enable preloaded programs and data.  

## 6. Testing & Verification  
- Each module has an associated testbench (`tb/<module>_tb.v`), automatically discovered by the Makefile.  
- Running `make` performs lint, build, simulation, waveform dumping, **and Vivado simulation** for all testbenches.  
- Schematic rendering (`make schem`) visualizes module structure, aiding design reviews.

> **Figure 4:** _Waveform Example_  
> ![Waveform Placeholder](path/to/waveform_example.png)

## 7. Challenges & Mitigations  
- **Instruction-alignment checks** in `next_pc` identify misaligned addresses during simulation, preventing silent control-flow errors.  
- **Branch diversity** is handled by a dedicated comparator module, simplifying decoder logic and ensuring extensibility.

## 8. Results  
The repository provides a complete, simulation-ready RISC-V core with comprehensive testbenches and an extensible build system. The modular design facilitates future enhancements, experimentation, and instructional use.

## 9. Future Work  
- Introduce pipelining to improve throughput.  
- Add hazard detection and forwarding.  
- Expand instruction coverage (e.g., system instructions, multiplication/division).  
- Integrate a cache or memory hierarchy for realistic performance evaluation.

## 10. Conclusion
This project delivers a clean, modular foundation for RISC-V CPU exploration. The codebase’s structure, documentation, and automated tooling—now including mandatory Vivado flows—make it suitable for both educational purposes and further research or development.

## Vivado Reports
The `logs/` directory contains Vivado-generated synthesis, timing, power, and rule-check reports for the `cpu` design. Key highlights include:

- Clock reports show the top-level `clk` is unconstrained, leaving 2,080 endpoints without timing analysis.
- A design rule check warns about a missing PS7 block (`ZPS7-1`).
- Methodology analysis flags 1,000 non-clocked sequential cells and extensive use of distributed RAM.
- Power analysis estimates total on-chip power of 3.618 W with the program counter consuming the largest share.
- Timing summary lists thousands of unconstrained internal endpoints and undefined I/O delays.
- Utilization reports 2,439 slice LUTs and 1,056 slice registers in use.

These reports guide next steps such as adding clock constraints, resolving DRC warnings, and optimizing resource usage.

---

### Testing
No tests were executed in this read-only review environment.

### Notes
This report is based on static inspection; dynamic behavior and performance were not validated.


## Appendix: Module Overview

### adder
Ripple-carry adder for summing operands.

![adder](../images/docs/adder.svg)
![adder schematic](../images/schematics/adder.svg)

### alu
Performs arithmetic and logic operations and sets a zero flag.

![alu](../images/docs/alu.svg)
![alu schematic](../images/schematics/alu.svg)

### alu_control
Decodes ALUOp and funct fields into a specific ALU control code.

![alu_control](../images/docs/alu_control.svg)
![alu_control schematic](../images/schematics/alu_control.svg)

### branch_comp
Compares operands and determines branch decisions.

![branch_comp](../images/docs/branch_comp.svg)
![branch_comp schematic](../images/schematics/branch_comp.svg)

### control
Top-level control logic driving datapath and memory sequencing.

![control](../images/docs/control.svg)
![control schematic](../images/schematics/control.svg)

### controller
Finite state machine orchestrating overall CPU execution.

![controller](../images/docs/controller.svg)
![controller schematic](../images/schematics/controller.svg)

### cpu
Top-level CPU wrapper combining controller and datapath modules.

![cpu](../images/docs/cpu.svg)
![cpu schematic](../images/schematics/cpu.svg)

### data_mem
Data memory providing load and store access.

![data_mem](../images/docs/data_mem.svg)
![data_mem schematic](../images/schematics/data_mem.svg)

### datapath
Wires registers, ALU, memories, and multiplexers together.

![datapath](../images/docs/datapath.svg)
![datapath schematic](../images/schematics/datapath.svg)

### decoder
Extracts instruction fields and produces basic control signals.

![decoder](../images/docs/decoder.svg)
![decoder schematic](../images/schematics/decoder.svg)

### decoder_glue
Auxiliary logic supporting decoder outputs.

![decoder_glue](../images/docs/decoder_glue.svg)
![decoder_glue schematic](../images/schematics/decoder_glue.svg)

### imm_gen
Generates immediate values from instruction fields.

![imm_gen](../images/docs/imm_gen.svg)
![imm_gen schematic](../images/schematics/imm_gen.svg)

### instr_mem
Instruction memory storage for program code.

![instr_mem](../images/docs/instr_mem.svg)
![instr_mem schematic](../images/schematics/instr_mem.svg)

### instr_slicer
Splits the instruction into its constituent fields.

![instr_slicer](../images/docs/instr_slicer.svg)
![instr_slicer schematic](../images/schematics/instr_slicer.svg)

### next_pc
Computes the next program counter value based on branch logic.

![next_pc](../images/docs/next_pc.svg)
![next_pc schematic](../images/schematics/next_pc.svg)

### pc
Program counter register holding the current instruction address.

![pc](../images/docs/pc.svg)
![pc schematic](../images/schematics/pc.svg)

### reg_file
Register file supporting two reads and one write each cycle.

![reg_file](../images/docs/reg_file.svg)
![reg_file schematic](../images/schematics/reg_file.svg)

### wb_mux
Selects the data source for register write-back.

![wb_mux](../images/docs/wb_mux.svg)
![wb_mux schematic](../images/schematics/wb_mux.svg)

