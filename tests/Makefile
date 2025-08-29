RISCV ?= riscv64-unknown-elf
CC    := $(RISCV)-gcc
OBJC  := $(RISCV)-objcopy

STATUS_ADDR ?= 0x0
STATUS_PASS ?= 0xC0DECAFE

CFLAGS := -march=rv32i -mabi=ilp32 -nostdlib -nostartfiles -Wl,-Tcommon.ld -static \
          -DSTATUS_ADDR=$(STATUS_ADDR) -DSTATUS_PASS=$(STATUS_PASS)
ASM    := r_alu.S i_alu.S branches.S jumps.S mem_rw.S x0_guard.S

all: $(ASM:.S=.mem)

%.elf: %.S common.ld PASS_INC.S
	$(CC) $(CFLAGS) -o $@ $<

%.mem: %.elf
	$(OBJC) -O binary $< $*.bin
	od -An -tx4 -v -w4 $*.bin | sed 's/ //g' | tr 'a-f' 'A-F' > $@
	rm -f $*.bin

clean:
	rm -f *.elf *.mem
