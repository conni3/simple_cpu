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

---

### Testing
No tests were executed in this read-only review environment.

### Notes
This report is based on static inspection; dynamic behavior and performance were not validated.

