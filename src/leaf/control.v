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
    output reg                   wb_sel,
    output reg                   alu_src,
    output reg                   branch_sig,
    output reg                   jump,
    output reg  [           1:0] alu_op,
    output reg  [           2:0] imm_sel
);

  always @(*) begin

    mem_read   = 1'b0;
    mem_write  = 1'b0;
    wb_sel     = 1'b0;
    alu_src    = 1'b0;
    branch_sig = 1'b0;
    jump       = 1'b0;
    alu_op     = 2'b00;
    imm_sel    = `Imm_NONE;

    if (is_alu_reg) begin
      alu_op = 2'b10;  // R-type
    end

    if (is_alu_imm) begin
      alu_src = 1'b1;  // I-type
      alu_op  = 2'b10;
      imm_sel = `Imm_I;
    end

    if (is_load) begin
      mem_read = 1'b1;
      wb_sel   = 1'b1;
      alu_src  = 1'b1;
      alu_op   = 2'b00;
      imm_sel  = `Imm_I;
    end

    if (is_store) begin
      mem_write = 1'b1;
      alu_src   = 1'b1;
      alu_op    = 2'b00;
      imm_sel   = `Imm_S;
    end

    if (is_branch) begin
      branch_sig = 1'b1;
      alu_op = 2'b01;
      imm_sel = `Imm_B;
    end

    if (is_jal) begin
      alu_src = 1'b1;
      jump = 1'b1;
      alu_op = 2'b00;
      imm_sel = `Imm_J;
    end

    if (is_jalr) begin
      alu_src = 1'b1;
      jump = 1'b1;
      alu_op = 2'b00;
      imm_sel = `Imm_I;
    end

    if (is_lui) begin
      alu_src = 1'b1;
      alu_op  = 2'b11;
      imm_sel = `Imm_U;
    end

    if (is_auipc) begin
      alu_src = 1'b1;
      alu_op  = 2'b00;
      imm_sel = `Imm_U;
    end

    if (is_system) begin
      // not done yet
    end

  end

endmodule
