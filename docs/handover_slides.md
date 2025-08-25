---
title: "CPU Project Handover"
author: "Your Name"
date: "2025-08-25"
---

# Project Overview

- 32-bit RV32I single-cycle CPU core
- Show architecture with controller and datapath blocks
![CPU schematic](cpu.svg)


---

# Agenda

1. Project context
2. Repository layout
3. Build & test commands
4. Vivado simulation demo
5. Controller & datapath tour
6. Handover checklist
7. Recording tips
8. Wrap-Up

---

# Project Context

- Goal: teaching-oriented single-cycle CPU
- Toolchain: Icarus/GTKWave or Vivado xsim
- Include a screenshot of README intro

![README snippet](images/snap_readme.png)

---

# Repository Layout

- `src/` : RTL modules
- `tb/` : testbenches
- `docs/` : module docs and schematics
- `Makefile` : build/sim automation
- Snapshot to capture: VS Code tree

![VS Code tree](images/snap_repo_tree.png)

---

# Build & Test

```bash
make           # run all Icarus tests
make schem     # regenerate SVG schematics
```

- Include terminal screenshot of successful `make`

![make output](images/snap_make.png)

---

# Vivado Simulation

```bash
make vivado comp=cpu      # elaborate
xsim work.cpu_tb          # run
```

- Demonstrate waveform with:
  - Program counter
  - Register file writes
  - Memory bus
- Snapshot to include: xsim waveform

![xsim wave](images/snap_wave_pc.png)

---

# Controller FSM

- Finite-state machine drives control signals
- Show fetch → decode → execute → mem → writeback

![Controller schematic](controller.svg)

---

# Datapath

- ALU, register file, memory, multiplexers
- Highlight control signal paths

![Datapath schematic](datapath.svg)

---

# Handover Checklist

- All tests pass
- Schematics regenerated
- TODOs noted in `docs/handover.md`
- Record demo video and store script

---

# Recording Tips

1. Start with slides, then VS Code, then Vivado
2. Pre-arrange waveforms and code windows
3. Keep narration < 10 minutes
- Optional snapshot: OBS layout

![OBS setup](images/snap_obs.png)

---

# Wrap-Up

- Review accomplishments & next steps
- Point to repository for details
- Thanks!