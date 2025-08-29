    .section .text
    .globl _start

_start:
    addi x1, x0, 5
    addi x2, x1, -3      
    xori x3, x2, 0xFF    
    ori  x4, x0, 0x300   
    andi x5, x4, 0x0F0   
    slli x6, x1, 4       
    srli x7, x6, 3       
    addi x8, x0, -128
    srai x9, x8, 2       
    slti x10, x8, -1     
    sltiu x11, x8, 1     

    
    li   t0, STATUS_PASS
    sw   t0, STATUS_ADDR(x0)
1:  jal  x0, 0
