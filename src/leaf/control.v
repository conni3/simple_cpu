`timescale 1ps / 1ps
`include "defines.vh"

module control #(
    parameter DATA_WIDTH = 32
) (
    input  wire [DATA_WIDTH-1:0] instr,
    input  wire                  is_alu_reg,
    input  wire                  is_alu_imm,
    input  wire                  is_branch,
    input  wire                  is_jal,
    input  wire                  is_jalr,
    input  wire                  is_lui,
    input  wire                  is_auipc,
    input  wire                  is_load,
    input  wire                  is_store,
    input  wire                  is_system,
    output reg                   mem_read,
    output reg                   mem_write,
    output reg                   alu_src,     // 0=rs2, 1=imm
    output reg                   branch_sig,
    output reg                   jump,
    output reg  [           1:0] alu_op,
    output reg  [           2:0] imm_sel,
    output reg  [           1:0] wb_sel,
    output reg  [           1:0] op1_sel      // OP1_RS1/PC/ZERO
);

  wire [2:0] funct3 = instr[14:12];

  always @(*) begin
    // ---- defaults ----
    mem_read   = 1'b0;
    mem_write  = 1'b0;
    alu_src    = 1'b0;
    branch_sig = 1'b0;
    jump       = 1'b0;
    alu_op     = 2'b00;  // ADD by default
    imm_sel    = `Imm_NONE;
    wb_sel     = `WB_ALU;
    op1_sel    = `OP1_RS1;  // rs1 by default

    // ---- ALU R-type ----
    if (is_alu_reg) begin
      alu_op  = 2'b10;
      op1_sel = `OP1_RS1;
    end

    // ---- ALU I-type ----
    if (is_alu_imm) begin
      alu_src = 1'b1;
      imm_sel = `Imm_I;
      op1_sel = `OP1_RS1;
      if (funct3 == 3'b000) alu_op = 2'b00;
      else alu_op = 2'b10;
    end

    // ---- LOAD ----
    if (is_load) begin
      mem_read = 1'b1;
      alu_src  = 1'b1;
      alu_op   = 2'b00;
      imm_sel  = `Imm_I;
      wb_sel   = `WB_MEM;
      op1_sel  = `OP1_RS1;
    end

    // ---- STORE ----
    if (is_store) begin
      mem_write = 1'b1;
      alu_src   = 1'b1;
      alu_op    = 2'b00;
      imm_sel   = `Imm_S;
      op1_sel   = `OP1_RS1;
    end

    // ---- BRANCH ----
    if (is_branch) begin
      branch_sig = 1'b1;
      alu_op     = 2'b01;
      imm_sel    = `Imm_B;
      op1_sel    = `OP1_RS1;
    end

    // ---- JAL ----
    if (is_jal) begin
      wb_sel  = `WB_PC4;
      jump    = 1'b1;
      alu_src = 1'b1;
      imm_sel = `Imm_J;
      alu_op  = 2'b00;
      op1_sel = `OP1_PC;
    end  // ---- JALR ----
    else if (is_jalr) begin
      wb_sel  = `WB_PC4;
      jump    = 1'b1;
      alu_src = 1'b1;
      imm_sel = `Imm_I;
      alu_op  = 2'b00;
      op1_sel = `OP1_RS1;
    end

    // ---- LUI ----
    if (is_lui) begin
      wb_sel  = `WB_ALU;
      alu_src = 1'b1;
      imm_sel = `Imm_U;
      alu_op  = 2'b00;
      op1_sel = `OP1_ZERO;
    end

    // ---- AUIPC ----
    if (is_auipc) begin
      wb_sel  = `WB_ALU;
      alu_src = 1'b1;
      imm_sel = `Imm_U;
      alu_op  = 2'b00;
      op1_sel = `OP1_PC;
    end
  end

endmodule
