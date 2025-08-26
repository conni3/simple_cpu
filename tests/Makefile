RISCV ?= riscv64-unknown-elf
CC    := $(RISCV)-gcc
OBJC  := $(RISCV)-objcopy

PASS_ADDR ?= 0x20
PASS_DATA ?= 0xC0DECAFE

CFLAGS := -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Wl,-Tcommon.ld -static \
          -DPASS_ADDR=$(PASS_ADDR) -DPASS_DATA=$(PASS_DATA)
ASM    := r_alu.S i_alu.S branches.S jumps.S mem_rw.S x0_guard.S

# rule: .S -> .elf -> .mem (32b words)
all: $(ASM:.S=.mem)

%.elf: %.S common.ld PASS_INC.S
	$(CC) $(CFLAGS) -o $@ $<

# Convert ELF to raw binary then dump as 32-bit little-endian words

%.mem: %.elf
	$(OBJC) -O binary $< $*.bin
	od -An -tx4 -v -w4 $*.bin | sed 's/ //g' | tr 'a-f' 'A-F' > $@
	rm -f $*.bin

clean:
	rm -f *.elf *.mem
