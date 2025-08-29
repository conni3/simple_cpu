    .section .text
    .globl _start

_start:
    addi x0, x0, 123     
    addi x1, x0, 0       
    addi x2, x0, 5
    sub  x0, x2, x2      

    beq  x1, x0, 1f      
    addi x0, x0, 1

1:  
    li   t0, STATUS_PASS
    sw   t0, STATUS_ADDR(x0)
1:  jal  x0, 0
