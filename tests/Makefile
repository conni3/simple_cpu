RISCV ?= riscv64-unknown-elf
CC    := $(RISCV)-gcc
OBJC  := $(RISCV)-objcopy

PASS_ADDR ?= 0x20
PASS_DATA ?= 0xC0DECAFE

CFLAGS := -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Wl,-Tcommon.ld -static \
          -DPASS_ADDR=$(PASS_ADDR) -DPASS_DATA=$(PASS_DATA)
ASM    := r_alu.S i_alu.S branches.S jumps.S mem_rw.S x0_guard.S

# rule: .S -> .elf -> .mem (verilog)
all: $(ASM:.S=.mem)

%.elf: %.S common.ld PASS_INC.S
	$(CC) $(CFLAGS) -o $@ $<

%.mem: %.elf
	# GNU objcopy's "verilog" format emits @addr headers and 32b words per line
	$(OBJC) -O verilog $< $@
	# Optionally append END_SENTINEL (jal x0,0) to be extra-clear for your TB:
	@echo "0000006f" >> $@

clean:
	rm -f *.elf *.mem
