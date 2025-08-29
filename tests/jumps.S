    .section .text
    .globl _start

_start:
    auipc x3, 0          
    jal   x1, 1f         
    addi  x0, x0, 1      
1:
    
    la    x5, 2f
    jalr  x2, 0(x5)      
    addi  x0, x0, 1      
2:
    
    li   t0, STATUS_PASS
    sw   t0, STATUS_ADDR(x0)
1:  jal  x0, 0
