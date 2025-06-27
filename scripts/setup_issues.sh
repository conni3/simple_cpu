#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# Ensure the "gh-milestone" extension is installed
# ----------------------------------------------------------------------
if ! gh extension list | grep -q 'gh-milestone'; then
  echo "Installing gh-milestone extension…"
  gh extension install valeriobelli/gh-milestone
fi

# ----------------------------------------------------------------------
# Milestones (flags mode + dummy due-date to skip prompt)
# ----------------------------------------------------------------------
gh milestone create \
  --title "Core Module Development" \
  --description "Implement all individual RTL blocks in Verilog." \
  --due-date "2025-06-30"
gh milestone create \
  --title "Unit Testing & Verification" \
  --description "Build and run a testbench for each RTL block, then a top-level CPU test." \
  --due-date "2025-07-02"
gh milestone create \
  --title "Vivado Project Setup & Integration" \
  --description "Create a reusable Vivado flow via Tcl, import RTL & TBs, and verify end-to-end simulation." \
  --due-date "2025-07-04"
gh milestone create \
  --title "Memory Initialization & Program Loading" \
  --description "Generate a program image, integrate it into your instruction ROM, and verify fetches." \
  --due-date "2025-07-11"


# ----------------------------------------------------------------------
# Milestone 1 Issues
# ----------------------------------------------------------------------
gh issue create --title "Implement Program Counter (pc.v)" \
  --body "Create pc.v with clk, reset, next_pc → current_pc logic." \
  --milestone "Core Module Development"
gh issue create --title "Implement Instruction Memory Wrapper (instr_mem.v)" \
  --body "Thin wrapper around Block Memory Generator IP for instruction fetch." \
  --milestone "Core Module Development"
gh issue create --title "Implement Register File (regfile.v)" \
  --body "32×32-bit regfile, two read ports, one write port." \
  --milestone "Core Module Development"
gh issue create --title "Implement Sign-Extend Unit (sign_extend.v)" \
  --body "16→32-bit immediate extension module." \
  --milestone "Core Module Development"
gh issue create --title "Implement ALU (alu.v)" \
  --body "Support add, sub, and, or, slt; produce Zero flag." \
  --milestone "Core Module Development"
gh issue create --title "Implement ALU Control (alu_control.v)" \
  --body "Map ALUOp + funct field → ALU control signals." \
  --milestone "Core Module Development"
gh issue create --title "Implement Control Unit (control.v)" \
  --body "Decode opcode → RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp." \
  --milestone "Core Module Development"
gh issue create --title "Implement Data Memory Wrapper (data_mem.v)" \
  --body "Wrapper around BRAM IP for loads/stores." \
  --milestone "Core Module Development"
gh issue create --title "Implement Adders & MUXes (adder.v, mux2.v)" \
  --body "PC+4 adder, branch-target adder; 2-to-1 mux modules." \
  --milestone "Core Module Development"

# ----------------------------------------------------------------------
# Milestone 2 Issues
# ----------------------------------------------------------------------
gh issue create --title "Write PC Testbench (pc_tb.v)" \
  --body "Test pc.v reset and next_pc behavior." \
  --milestone "Unit Testing & Verification"
gh issue create --title "Write InstrMem Testbench (instr_mem_tb.v)" \
  --body "Test instruction memory wrapper read behavior." \
  --milestone "Unit Testing & Verification"
gh issue create --title "Write RegFile Testbench (regfile_tb.v)" \
  --body "Test regfile read/write operations and reset state." \
  --milestone "Unit Testing & Verification"
gh issue create --title "Write Sign-Extend Testbench (sign_extend_tb.v)" \
  --body "Validate 16→32-bit immediate extension outputs." \
  --milestone "Unit Testing & Verification"
gh issue create --title "Write ALU Testbench (alu_tb.v)" \
  --body "Test add, sub, and, or, slt operations and Zero flag." \
  --milestone "Unit Testing & Verification"
gh issue create --title "Write ALU Control Testbench (alu_control_tb.v)" \
  --body "Validate ALU control code generation from ALUOp+funct." \
  --milestone "Unit Testing & Verification"
gh issue create --title "Write Control Unit Testbench (control_tb.v)" \
  --body "Check control signal outputs for all opcodes." \
  --milestone "Unit Testing & Verification"
gh issue create --title "Write DataMem Testbench (data_mem_tb.v)" \
  --body "Test data memory read/write timing and data paths." \
  --milestone "Unit Testing & Verification"
gh issue create --title "Write Adders & MUXes Testbenches (adder_tb.v, mux2_tb.v)" \
  --body "Validate both adders and 2:1 mux functionality." \
  --milestone "Unit Testing & Verification"
gh issue create --title "Write Top-Level CPU Testbench (cpu_tb.v)" \
  --body "Instantiate cpu.v, drive a sequence (e.g., add, beq), and check register outputs." \
  --milestone "Unit Testing & Verification"

# ----------------------------------------------------------------------
# Milestone 3 Issues
# ----------------------------------------------------------------------
gh issue create --title "Write Vivado Tcl Project Script (build/cpu_design.tcl)" \
  --body "Automate project creation, add files, set tops, and launch runs." \
  --milestone "Vivado Project Setup & Integration"
gh issue create --title "Add RTL to Vivado via Tcl" \
  --body "Use add_files for src/*.v in the Tcl script." \
  --milestone "Vivado Project Setup & Integration"
gh issue create --title "Add Simulation Sources via Tcl" \
  --body "Wire up tb/*.v under the sim_1 fileset in Tcl." \
  --milestone "Vivado Project Setup & Integration"
gh issue create --title "Set Top Modules for Synth & Sim" \
  --body "Use set_property top for cpu.v (synth) and cpu_tb.v (sim)." \
  --milestone "Vivado Project Setup & Integration"
gh issue create --title "Run Behavioral Simulation in Batch" \
  --body "Invoke launch_runs sim_1 to verify functionality in Vivado." \
  --milestone "Vivado Project Setup & Integration"
gh issue create --title "Debug Integration Failures" \
  --body "Fix any mismatches discovered during batch simulation." \
  --milestone "Vivado Project Setup & Integration"

# ----------------------------------------------------------------------
# Milestone 4 Issues
# ----------------------------------------------------------------------
gh issue create --title "Assemble Sample Program" \
  --body "Write/assemble a small test program (e.g., add, load/store)." \
  --milestone "Memory Initialization & Program Loading"
gh issue create --title "Generate Hex Dump or COE File" \
  --body "Convert assembled binary into instr.hex or .coe format." \
  --milestone "Memory Initialization & Program Loading"
gh issue create --title "Integrate COE into BRAM IP" \
  --body "Point your Block Memory Generator to the .coe file for ROM init." \
  --milestone "Memory Initialization & Program Loading"
gh issue create --title "Implement \$readmemh-based ROM Module" \
  --body "Alternative to use initial \$readmemh(\"instr.hex\", mem) in Verilog." \
  --milestone "Memory Initialization & Program Loading"
gh issue create --title "Simulate Program Fetch & Execution" \
  --body "Run behavioral sim fetching and executing your sample program." \
  --milestone "Memory Initialization & Program Loading"


