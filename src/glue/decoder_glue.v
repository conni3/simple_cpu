`timescale 1ns / 1ps
`include "defines.vh"
// `defines.vh` can hold WB encodings if you prefer

module decoder_glue #(
    parameter DATA_WIDTH = 32
) (
    input wire [31:0] instr,

    // immediates
    output wire [DATA_WIDTH-1:0] imm_out,

    // controls to datapath
    output wire       reg_write,
    output wire       mem_read,
    output wire       mem_write,
    output wire       alu_src,
    output wire [1:0] op1_sel,
    output wire [1:0] wb_sel,

    output wire       branch_sig,
    output wire       jump,
    output wire [1:0] alu_op,
    output wire [2:0] imm_sel,

    // optional: for next_pc/traps/etc.
    output wire is_jal,
    output wire is_jalr,
    output wire is_branch,
    output wire is_lui,
    output wire is_auipc,
    output wire is_alu_reg,
    output wire is_alu_imm,
    output wire is_load,
    output wire is_store,
    output wire is_system

);

  // -------- slicer --------
  wire [4:0] rd = instr[11:7];
  wire [4:0] rs1 = instr[19:15];
  wire [4:0] rs2 = instr[24:20];

  // -------- coarse decode --------
  decoder #(
      .DATA_WIDTH(DATA_WIDTH)
  ) u_dec (
      .instr     (instr),
      .is_alu_reg(is_alu_reg),
      .reg_write (reg_write),   // If control also drives reg_write, disconnect this.
      .is_jal    (is_jal),
      .is_jalr   (is_jalr),
      .is_branch (is_branch),
      .is_lui    (is_lui),
      .is_auipc  (is_auipc),
      .is_alu_imm(is_alu_imm),
      .is_load   (is_load),
      .is_store  (is_store),
      .is_system (is_system)
  );

  // -------- main control --------
  control #(
      .DATA_WIDTH(DATA_WIDTH)
  ) u_ctl (
      .instr     (instr),
      .is_alu_reg(is_alu_reg),
      .is_alu_imm(is_alu_imm),
      .is_branch (is_branch),
      .is_jal    (is_jal),
      .is_jalr   (is_jalr),
      .is_lui    (is_lui),
      .is_auipc  (is_auipc),
      .is_load   (is_load),
      .is_store  (is_store),
      .is_system (is_system),

      .mem_read  (mem_read),
      .mem_write (mem_write),
      .alu_src   (alu_src),
      .branch_sig(branch_sig),
      .jump      (jump),
      .alu_op    (alu_op),
      .imm_sel   (imm_sel),
      .wb_sel    (wb_sel),
      .op1_sel   (op1_sel)
  );

  // -------- immediate gen --------
  imm_gen u_imm (
      .instr  (instr),
      .imm_sel(imm_sel),  // `Imm_I/S/B/U/J` from defines.vh
      .imm_out(imm_out)
  );


endmodule
