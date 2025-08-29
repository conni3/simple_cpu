    .section .text
    .globl _start

_start:
    addi x1, x0, 10
    addi x2, x0, 10
    addi x3, x0, -1
    addi x4, x0, 1

    beq  x1, x2, 1f      
    addi x0, x0, 1       
1:
    bne  x1, x2, 2f      
    addi x5, x0, 111     
2:
    blt  x3, x4, 3f      
    addi x0, x0, 1
3:
    bltu x3, x4, 4f      
    addi x6, x0, 222     
4:
    bge  x1, x2, 5f      
    addi x0, x0, 1
5:
    bgeu x4, x3, 6f      
    addi x0, x0, 1
6:
    
    li   t0, STATUS_PASS
    sw   t0, STATUS_ADDR(x0)
1:  jal  x0, 0
