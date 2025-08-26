    .section .text
    .globl _start
#include "PASS_INC.S"
_start:
    addi x1, x0, 5
    addi x2, x1, -3      # 2
    xori x3, x2, 0xFF    # 0x000000FD ^ 0xFF = 0x00000002 ? careful: x2=2 => 2 ^ 255 = 253
    ori  x4, x0, 0x300   # 0x300
    andi x5, x4, 0x0F0   # 0x300 & 0x0F0 = 0x00000000
    slli x6, x1, 4       # 80
    srli x7, x6, 3       # 10
    addi x8, x0, -128
    srai x9, x8, 2       # -32 (arith)
    slti x10, x8, -1     # 1 (signed compare)
    sltiu x11, x8, 1     # x8 is 0xFFFFFF80; 0xFFFFFF80 < 1 (unsigned)? no => 0

    # PASS
    li   t0, STATUS_PASS
    sw   t0, STATUS_ADDR(x0)
1:  jal  x0, 0
