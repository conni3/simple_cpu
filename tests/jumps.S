    .section .text
    .globl _start
_start:
    auipc x3, 0          # x3 = PC
    jal   x1, 1f         # x1 = link = PC+4
    addi  x0, x0, 1      # skipped
1:
    # Check jalr target: set x5 to absolute addr of label 2f
    la    x5, 2f
    jalr  x2, 0(x5)      # x2 = link, jump to 2f
    addi  x0, x0, 1      # skipped
2:
    # PASS
    lui  x14, %hi(0xC0DECAFE)
    addi x14, x14, %lo(0xC0DECAFE)
    sw   x14, 0x20(x0)
1:  jal  x0, 0
