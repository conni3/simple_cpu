# Makefile for Icarus simulations, dumping VCDs into waves/<module>.vcd

ifdef comp
  ifeq ($(comp),cpu)
    SRC := $(shell ls src/*.v)
    TB  := tb/cpu_tb.v
    MODULE := cpu
  else
    SRC := src/$(comp).v
    TB  := tb/$(comp)_tb.v
    MODULE := $(comp)
  endif
else
  SRC    := $(shell ls src/*.v)
  ALL_TB := $(shell ls tb/*_tb.v)
  TB     := $(filter-out tb/cpu_tb.v,$(ALL_TB)) tb/cpu_tb.v
  MODULE := all
endif


OUT      := simv
VCD_DIR  := waves
VCD      := $(VCD_DIR)/$(MODULE).vcd

IVERILOG := iverilog
VVP      := vvp
GTK      := gtkwave

.PHONY: all sim wave clean

all: sim

sim: $(SRC) $(TB)
	@echo "=== Compiling for module: $(MODULE) ==="
	$(IVERILOG) -g2012 -o $(OUT) $(SRC) $(TB)
	@mkdir -p $(VCD_DIR)
	@echo "=== Running simulation ==="
	$(VVP) $(OUT)
	@mv dump.vcd $(VCD)
	@echo "=== Waveform saved to $(VCD) ==="

wave: sim
	@echo "=== Launching GTKWave: $(VCD) ==="
	$(GTK) $(VCD) &

clean:
	rm -f $(OUT)
	rm -rf $(VCD_DIR)
