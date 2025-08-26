    .section .text
    .globl _start
#include "PASS_INC.S"
_start:
    # x1=7, x2=3
    addi x1, x0, 7
    addi x2, x0, 3

    add  x3, x1, x2      # 10
    sub  x4, x1, x2      # 4
    and  x5, x1, x2      # 7 & 3 = 3
    or   x6, x1, x2      # 7 | 3 = 7
    xor  x7, x1, x2      # 4
    sll  x8, x2, x1      # 3 << 7 = 384
    srl  x9, x1, x2      # 7 >> 3 = 0
    addi x10, x0, -1
    sra  x11, x10, x2    # (-1) >> 3 = -1 (arith)
    slt  x12, x2, x1     # 3<7 => 1
    sltu x13, x2, x1     # 1

    # PASS
    li   t0, PASS_DATA
    sw   t0, PASS_ADDR(x0)
1:  jal  x0, 0            # END_SENTINEL (your TB also appends one)
