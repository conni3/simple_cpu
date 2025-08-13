# Makefile for mixed Icarus and Vivado XSIM simulations

SHELL := /bin/bash
$(shell mkdir -p logs)

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# ------------------------------------------------------------------
# Vivado installation path and version (overrideable via command line)
# ------------------------------------------------------------------
VIVADO_VERSION ?= 2025.1
VIVADO_SETTINGS ?= /opt/Xilinx/Vivado/$(VIVADO_VERSION)/$(VIVADO_VERSION)/Vivado/settings64.sh

# ------------------------------------------------------------------
# Module selection logic (comp optional)
# ------------------------------------------------------------------
LEAF := $(shell find src/leaf -type f \( -name '*.v' -o -name '*.sv' \) 2>/dev/null | sort)
GLUE := $(shell find src/glue -type f \( -name '*.v' -o -name '*.sv' \) 2>/dev/null | sort)
TOPS := $(shell find src/top  -type f \( -name '*.v' -o -name '*.sv' \) 2>/dev/null | sort)
RTL  := $(LEAF) $(GLUE) $(TOPS)

ifdef comp
	  SRC     := $(shell -O globstar -c 'ls src/**/*.v')
	  TB      := tb/$(comp)_tb.v
	  MODULE  := $(comp)
else
	SRC       := $(shell ls src/*.v)
	ALL_TB    := $(shell ls tb/*_tb.v)
	TB        := $(filter-out tb/cpu_tb.v,$(ALL_TB)) tb/cpu_tb.v
	MODULE    := all
endif

# ------------------------------------------------------------------
# Icarus Verilog settings
# ------------------------------------------------------------------
OUT       := simv
VCD_DIR   := waves
VCD       := $(VCD_DIR)/$(MODULE).vcd

IVERILOG  := iverilog
VVP       := vvp
GTK       := gtkwave

# ------------------------------------------------------------------
# Vivado XSIM settings
# ------------------------------------------------------------------
RUN_TCL   := run_$(MODULE).tcl
SIM_NAME  := $(MODULE)_sim

.PHONY: all lint_iverilog sim_iverilog sim_iverilog_wave sim_xsim clean

all: sim_iverilog sim_xsim

# Icarus lint
lint_iverilog:
	@echo "=== Icarus: linting sources for module: $(MODULE) ==="
	$(IVERILOG) -g2012 -Wall -o /dev/null $(SRC) $(TB)
	@echo "=== Icarus lint successful ==="

# Icarus simulation
sim_iverilog: $(SRC) $(TB) | $(VCD_DIR)
	@echo "=== Icarus: compiling for module: $(MODULE) ==="
	$(IVERILOG) -g2012 -o $(OUT) $(SRC) $(TB)
	@echo "=== Running simulation ==="
	$(VVP) $(OUT)
	@mv dump.vcd $(VCD)
	@echo "=== VCD dumped to $(VCD) ==="

$(VCD_DIR):
	@mkdir -p $(VCD_DIR)

sim_iverilog_wave: sim_iverilog
	@echo "=== Launching GTKWave for $(VCD) ==="
	$(GTK) $(VCD) &

# Vivado simulation
sim_xsim: $(SRC) $(TB)
	@echo "=== Compiling ==="
	xvlog -sv $(SRC) $(TB)
	@echo "=== Elaborating ==="
	# snapshot is MODULE_sim so comp=regfile ⇒ snapshot=regfile_sim
	xelab -debug typical -snapshot $(MODULE)_sim work.$(MODULE)_tb
	@echo "=== Running Simulation ==="
	xsim $(MODULE)_sim --runall

# Generate TCL batch for XSIM
$(RUN_TCL):
	@echo "add_wave *" > $(RUN_TCL)
	@echo "run 1000ns" >> $(RUN_TCL)
	@echo "quit" >> $(RUN_TCL)

clean:
	@echo "=== Cleaning up ==="
	rm -f $(OUT) $(RUN_TCL) *.jou *.log *.wdb dump.vcd
	rm -rf $(VCD_DIR) obj_dir
