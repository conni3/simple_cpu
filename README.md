
## Modules

### leaf modules

| Module      | Inputs                                                                    | Outputs                                                             | Notes                                       |
| ----------- | ------------------------------------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------- |
| adder       | a, b                                                                      | result                                                              |                                             |
| alu_control | ALUOp, funct3, funct7_5                                                   | ALUCtrl                                                             | separate shifting                           |
| alu         | operand_a, operand_b, alu_control                                         | alu_result, zero                                                    | how would this work with separate shifting? |
| branch_comp | op1, op2, funct3                                                          | branch                                                              |                                             |
| control     | instr, ALUreg, ALUimm, Branch, JAL, JALR, LUI, AUIPC, Load, Store, SYSTEM | Memread, Memwrite, MemtoReg, ALUSrc, BranchSig, Jump, ALUOp, ImmSrc | change naming                               |


