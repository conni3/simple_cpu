`timescale 1ns / 1ps
`include "defines.vh"

module controller (
    input wire [31:0] instr,

    output wire [ 6:0] opcode,
    output wire [ 4:0] rd,
    output wire [ 2:0] funct3,
    output wire [ 4:0] rs1,
    output wire [ 4:0] rs2,
    output wire [ 6:0] funct7,
    output wire [19:0] csr,

    output wire [ 3:0] alu_ctrl,
    output wire [31:0] imm_out,
    output wire        reg_write,
    output wire        mem_read,
    output wire        mem_write,
    output wire        alu_src,
    output wire [ 1:0] op1_sel,
    output wire [ 1:0] wb_sel,

    output wire is_branch,
    output wire is_jal,
    output wire is_jalr
);


  assign opcode = instr[6:0];
  assign rd     = instr[11:7];
  assign funct3 = instr[14:12];
  assign rs1    = instr[19:15];
  assign rs2    = instr[24:20];
  assign funct7 = instr[31:25];
  assign csr    = instr[31:20];

  wire [1:0] alu_op;
  wire [2:0] imm_sel;

  decoder_glue u_decoder_glue (
      .instr    (instr),
      .imm_out  (imm_out),
      .reg_write(reg_write),
      .mem_read (mem_read),
      .mem_write(mem_write),
      .alu_src  (alu_src),
      .alu_op   (alu_op),
      .imm_sel  (imm_sel),
      .wb_sel   (wb_sel),
      .is_jal   (is_jal),
      .is_jalr  (is_jalr),
      .is_branch(is_branch),
      .op1_sel  (op1_sel)
  );

  wire funct7_5 =
    (opcode == `OP_RTYPE && (funct3 == 3'b000 || funct3 == 3'b101)) ? instr[30] :
    (opcode == `OP_ITYPE &&  funct3 == 3'b101)                       ? instr[30] :
    1'b0;

  alu_control u_alu_control (
      .alu_op  (alu_op),
      .funct3  (funct3),
      .funct7_5(funct7_5),
      .alu_ctrl(alu_ctrl)
  );

endmodule
