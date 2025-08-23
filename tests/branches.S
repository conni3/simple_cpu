    .section .text
    .globl _start
_start:
    addi x1, x0, 10
    addi x2, x0, 10
    addi x3, x0, -1
    addi x4, x0, 1

    beq  x1, x2, 1f      # taken
    addi x0, x0, 1       # must be skipped
1:
    bne  x1, x2, 2f      # not taken
    addi x5, x0, 111     # executed
2:
    blt  x3, x4, 3f      # -1 < 1 => taken
    addi x0, x0, 1
3:
    bltu x3, x4, 4f      # unsigned: (0xFFFF_FFFF) < 1 ? no => not taken
    addi x6, x0, 222     # executed
4:
    bge  x1, x2, 5f      # 10 >= 10 => taken
    addi x0, x0, 1
5:
    bgeu x4, x3, 6f      # unsigned: 1 >= 0xFFFF_FFFF => yes, taken
    addi x0, x0, 1
6:
    # PASS
    lui  x14, %hi(0xC0DECAFE)
    addi x14, x14, %lo(0xC0DECAFE)
    sw   x14, 0x20(x0)
1:  jal  x0, 0
