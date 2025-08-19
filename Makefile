SHELL := /bin/bash
$(shell mkdir -p logs)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

VIVADO_VERSION ?= 2025.1
VIVADO_SETTINGS ?= /opt/Xilinx/Vivado/$(VIVADO_VERSION)/$(VIVADO_VERSION)/Vivado/settings64.sh
VIVADO_ENV := source $(VIVADO_SETTINGS) >/dev/null 2>&1 || true;

LEAF := $(shell find src/leaf -type f \( -name '*.v' -o -name '*.sv' \) 2>/dev/null | sort)
GLUE := $(shell find src/glue -type f \( -name '*.v' -o -name '*.sv' \) 2>/dev/null | sort)
TOPS := $(shell find src/top  -type f \( -name '*.v' -o -name '*.sv' \) 2>/dev/null | sort)
RTL  := $(LEAF) $(GLUE) $(TOPS)

ALL_TB   := $(shell ls tb/*_tb.v 2>/dev/null)
TB_NAMES := $(patsubst tb/%_tb.v,%,$(ALL_TB))

IVERILOG := iverilog
VVP      := vvp
IVFLAGS  := -g2012 -I include
GTK      := gtkwave

XSVLOG := xvlog
XELAB  := xelab
XSIM   := xsim
XSIM_VLOG_FLAGS := -sv -i include
XSIM_ELAB_FLAGS := -debug typical

OUT_DIR := .build
VCD_DIR := waves
$(OUT_DIR): ; @mkdir -p $@
$(VCD_DIR): ; @mkdir -p $@

ifdef comp
  MODULE := $(comp)
  TBFILE := tb/$(MODULE)_tb.v
  TARGET := $(OUT_DIR)/$(MODULE).vvp
  VCD    := $(VCD_DIR)/$(MODULE).vcd
else
  MODULE := all
endif

.PHONY: help check build compile test run wave vivado vivado-all clean

all: test

help:
	@echo "Targets:";
	@echo "  make check [comp=mod]  - Lint with Icarus";
	@echo "  make build [comp=mod]  - Compile to .vvp";
	@echo "  make test  [comp=mod]  - Compile & run with Icarus";
	@echo "  make wave  comp=mod    - Run & open GTKWave";
	@echo "  make vivado comp=mod   - Run with Vivado XSIM";
	@echo "  make vivado-all        - Run all TBs with Vivado XSIM";
	@echo "  make clean             - Remove outputs";
	@echo "Variables:";
	@echo "  comp=mod               - Select a single testbench (e.g., comp=decoder)";

ifdef comp

check:
	@echo "=== Icarus: linting $(MODULE) ==="
	$(IVERILOG) $(IVFLAGS) -Wall -o /dev/null $(LEAF) $(GLUE) $(TOPS) $(TBFILE)
	@echo "=== Lint OK ==="

build compile: $(TARGET)

$(TARGET): $(RTL) $(TBFILE) | $(OUT_DIR)
	$(IVERILOG) $(IVFLAGS) -s $(MODULE)_tb -o $@ $(LEAF) $(GLUE) $(TOPS) $(TBFILE)

test run: build | $(VCD_DIR)
	@echo "=== Icarus: running $(MODULE) ==="
	$(VVP) $(TARGET)
	@test -f dump.vcd && mv -f dump.vcd $(VCD) || true
	@test -f $(VCD) && echo "=== VCD: $(VCD) ===" || true

wave: test
	@echo "=== GTKWave: $(VCD) ==="
	$(GTK) $(VCD) &

vivado: $(RTL) $(TBFILE)
	@echo "=== Vivado XSIM: $(MODULE) ==="
	bash -lc '$(VIVADO_ENV) $(XSVLOG) $(XSIM_VLOG_FLAGS) $(RTL) $(TBFILE)'
	bash -lc '$(VIVADO_ENV) $(XELAB) $(XSIM_ELAB_FLAGS) -snapshot $(MODULE)_sim work.$(MODULE)_tb'
	bash -lc '$(VIVADO_ENV) $(XSIM) $(MODULE)_sim --runall'

else  # =================== ALL MODULES ===================

check:
	@echo "=== Icarus: linting all testbenches ==="
	@set -e; for tb in $(ALL_TB); do \
	  name=$${tb#tb/}; name=$${name%_tb.v}; \
	  echo "-- $$name"; \
	  $(IVERILOG) $(IVFLAGS) -Wall -o /dev/null $(LEAF) $(GLUE) $(TOPS) $$tb || exit 1; \
	done
	@echo "=== Lint OK ==="

OUTS := $(addprefix $(OUT_DIR)/,$(addsuffix .vvp,$(TB_NAMES)))
VCDS := $(addprefix $(VCD_DIR)/,$(addsuffix .vcd,$(TB_NAMES)))

build compile: $(OUTS)

$(OUT_DIR)/%.vvp: tb/%_tb.v $(RTL) | $(OUT_DIR)
	$(IVERILOG) $(IVFLAGS) -s $*_tb -o $@ $(LEAF) $(GLUE) $(TOPS) tb/$*_tb.v

test run: build | $(VCD_DIR)
	@set -e; for f in $(OUTS); do \
	  name=$${f#$(OUT_DIR)/}; name=$${name%.vvp}; \
	  echo "==> $$name"; \
	  $(VVP) $$f; \
	  if [ -f dump.vcd ]; then mv -f dump.vcd $(VCD_DIR)/$$name.vcd; fi; \
	done
	@echo "=== All sims complete ==="

wave:
	@echo "Open a VCD with: gtkwave waves/<tb_name>.vcd"

vivado-all:
	@set -e; for tb in $(ALL_TB); do \
	  name=$${tb#tb/}; name=$${name%_tb.v}; \
	  echo "=== Vivado XSIM: $$name ==="; \
	  bash -lc '$(VIVADO_ENV) $(XSVLOG) $(XSIM_VLOG_FLAGS) $(RTL) '$$tb; \
	  bash -lc '$(VIVADO_ENV) $(XELAB) $(XSIM_ELAB_FLAGS) -snapshot '$$name'_sim work.'$$name'_tb'; \
	  bash -lc '$(VIVADO_ENV) $(XSIM) '$$name'_sim --runall'; \
	done

endif

clean:
	@echo "=== Cleaning up ==="
	rm -rf $(OUT_DIR) $(VCD_DIR) *.vcd *.wdb *.jou *.log *.pb work xsim.dir .Xil simv simv.vcd dump.vcd *.wcfg *.str
	

YOSYS       ?= yosys
JQ          ?= jq
NETLISTSVG  ?= netlistsvg
SCHEM_DIR   ?= images

RTL ?= $(shell find src -type f \( -name '*.v' -o -name '*.sv' \) | sort)
YS_READ_CMDS = verilog_defaults -add -I include; $(foreach f,$(RTL),read_verilog -sv $(f); )

.PHONY: mods schem schem-top schem-clean
$(SCHEM_DIR): ; @mkdir -p $@

mods:
	@$(YOSYS) -q -p "$(YS_READ_CMDS); proc; write_json /dev/stdout" \
	| $(JQ) -r '.modules | keys[] | select(startswith("$$")|not)'

schem: $(SCHEM_DIR)
	@command -v $(YOSYS) >/dev/null || { echo "yosys not found"; exit 1; }
	@command -v $(JQ)    >/dev/null || { echo "jq not found"; exit 1; }
	@command -v $(NETLISTSVG) >/dev/null || { echo "netlistsvg not found"; exit 1; }
	@mods="$$( $(YOSYS) -q -p '$(YS_READ_CMDS); proc; write_json /dev/stdout' \
	          | $(JQ) -r '.modules | keys[] | select(startswith("$$")|not)' )"; \
	if [ -z "$$mods" ]; then echo "No modules found."; exit 1; fi; \
	echo "== Rendering (per‑module JSON) =="; \
	for m in $$mods; do \
	  echo "→ $$m"; \
	  $(YOSYS) -q -p "$(YS_READ_CMDS); hierarchy -check -top $$m; \
	    proc; memory -nomap; opt; opt_clean; write_json $(SCHEM_DIR)/$$m.json"; \
	  $(NETLISTSVG) $(SCHEM_DIR)/$$m.json -o $(SCHEM_DIR)/$$m.svg; \
	done; \
	echo "== Schematics in $(SCHEM_DIR)/ =="

schem-top: $(SCHEM_DIR)
	@[ -n "$(comp)" ] || { echo "Usage: make schem-top comp=<module_name>"; exit 2; }
	@$(YOSYS) -q -p "$(YS_READ_CMDS); hierarchy -check -top $(comp); \
	  proc; memory -nomap; opt; opt_clean; write_json $(SCHEM_DIR)/$(comp).json"
	@$(NETLISTSVG) $(SCHEM_DIR)/$(comp).json -o $(SCHEM_DIR)/$(comp).svg

schem-clean:
	@rm -f $(SCHEM_DIR)/*.json $(SCHEM_DIR)/*.svg
