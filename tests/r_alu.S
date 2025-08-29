    .section .text
    .globl _start

_start:
    
    addi x1, x0, 7
    addi x2, x0, 3

    add  x3, x1, x2      
    sub  x4, x1, x2      
    and  x5, x1, x2      
    or   x6, x1, x2      
    xor  x7, x1, x2      
    sll  x8, x2, x1      
    srl  x9, x1, x2      
    addi x10, x0, -1
    sra  x11, x10, x2    
    slt  x12, x2, x1     
    sltu x13, x2, x1     

    
    li   t0, STATUS_PASS
    sw   t0, STATUS_ADDR(x0)
1:  jal  x0, 0            
