`timescale 1ns / 1ps
`include "defines.vh"

module decoder #(
    parameter DATA_WIDTH = 32
) (
    input wire [DATA_WIDTH-1:0] instr,
    output wire is_alu_reg,
    output wire reg_write,
    output wire is_jal,
    output wire is_jalr,
    output wire is_branch,
    output wire is_lui,
    output wire is_auipc,
    output wire is_alu_imm,
    output wire is_load,
    output wire is_store,
    output wire is_system
);

  wire [6:0] opcode = instr[6:0];

  assign is_alu_reg = (opcode == `OP_RTYPE);  // rd <- rs1 OP rs2   
  assign is_alu_imm = (opcode == `OP_ITYPE);  // rd <- rs1 OP Iimm
  assign is_branch = (opcode == `OP_BRANCH);  // if(rs1 OP rs2) PC<-PC+Bimm
  assign is_jalr = (opcode == `OP_JALR && instr[14:12] == 3'b000);  // rd <- PC+4; PC<-rs1+Iimm
  assign is_jal = (opcode == `OP_JAL);  // rd <- PC+4; PC<-PC+Jimm
  assign is_auipc = (opcode == `OP_AUIPC);  // rd <- PC + Uimm
  assign is_lui = (opcode == `OP_LUI);  // rd <- Uimm   
  assign is_load = (opcode == `OP_LOAD);  // rd <- mem[rs1+Iimm]
  assign is_store = (opcode == `OP_STORE);  // mem[rs1+Simm] <- rs2
  assign is_system = (opcode == `OP_SYSTEM);  // special

  assign reg_write = is_alu_reg || is_alu_imm || is_load || is_lui || is_auipc || is_jal || is_jalr;

endmodule
