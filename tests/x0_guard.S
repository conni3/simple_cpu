    .section .text
    .globl _start
#include "PASS_INC.S"
_start:
    addi x0, x0, 123     # should have no effect
    addi x1, x0, 0       # expect x1=0
    addi x2, x0, 5
    sub  x0, x2, x2      # x0 must remain 0

    beq  x1, x0, 1f      # should be taken (both 0)
    addi x0, x0, 1

1:  # PASS
    li   t0, PASS_DATA
    sw   t0, PASS_ADDR(x0)
1:  jal  x0, 0
