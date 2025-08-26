    .section .text
    .globl _start
#include "PASS_INC.S"
_start:
    # Write pattern to four words @ 0x100..0x10C, then sum to x10
    lui  x1, %hi(0x00000100)
    addi x1, x1, %lo(0x00000100)

    addi x2, x0, 1
    addi x3, x0, 2
    addi x4, x0, 3
    addi x5, x0, 4

    sw   x2, 0(x1)
    sw   x3, 4(x1)
    sw   x4, 8(x1)
    sw   x5, 12(x1)

    lw   x6, 0(x1)
    lw   x7, 4(x1)
    lw   x8, 8(x1)
    lw   x9, 12(x1)
    add  x10, x6, x7
    add  x10, x10, x8
    add  x10, x10, x9     # x10 = 10

    # PASS
    li   t0, PASS_DATA
    sw   t0, PASS_ADDR(x0)
1:  jal  x0, 0
