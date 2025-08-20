`timescale 1ns / 1ps
`include "defines.vh"

module decoder_glue #(
    parameter int DATA_WIDTH = 32
) (
    input wire [31:0] instr,

    // sliced fields
    output wire [4:0] rd,
    output wire [4:0] rs1,
    output wire [4:0] rs2,

    // immediates
    output wire [31:0] imm_out,

    // controls to datapath
    output wire       reg_write,
    output wire       mem_read,
    output wire       mem_write,
    output wire       alu_src,
    output wire       branch_sig,
    output wire       jump,
    output wire [1:0] alu_op,
    output wire [2:0] imm_sel,     // optional to expose
    output wire [1:0] wb_sel,      // -> wb_mux (0:ALU, 1:MEM, 2:PC+4)

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
  assign rd  = instr[11:7];
  assign rs1 = instr[19:15];
  assign rs2 = instr[24:20];

  // -------- coarse decode --------
  decoder #(
      .DATA_WIDTH(DATA_WIDTH)
  ) u_dec (
      .instr     (instr),
      .is_alu_reg(is_alu_reg),
      .reg_write (reg_write),
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
  wire wb_sel_mem;
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
      .wb_sel    (wb_sel_mem),
      .alu_src   (alu_src),
      .branch_sig(branch_sig),
      .jump      (jump),
      .alu_op    (alu_op),
      .imm_sel   (imm_sel)
  );

  // -------- immediate gen --------
  imm_gen u_imm (
      .instr  (instr),
      .imm_sel(imm_sel),  // uses `Imm_I/S/B/U/J` from defines.vh
      .imm_out(imm_out)
  );

  // -------- writeback select (for wb_mux) --------
  assign wb_sel = (is_jal | is_jalr) ? 2'd2 :  // PC+4
      (wb_sel_mem) ? 2'd1 :  // MEM
      2'd0;  // ALU
endmodule
