`timescale 1ns / 1ps
`include "include/defines.vh"

module decoder_glue #(
    parameter DATA_WIDTH = 32
) (
    input wire [31:0] instr,

    // sliced fields
    output wire [4:0] rd,
    output wire [4:0] rs1,
    output wire [4:0] rs2,

    // immediates
    output wire [31:0] imm,

    // controls to datapath
    output wire       regWrite,
    output wire       MemRead,
    output wire       MemWrite,
    output wire       ALUSrc,
    output wire       BranchSig,
    output wire       Jump,
    output wire [1:0] ALUOp,
    output wire [2:0] ImmSrc,     // optional to expose
    output wire [1:0] wb_sel,     // -> wb_mux (0:ALU, 1:MEM, 2:PC+4)

    // optional: for next_pc/traps/etc.
    output wire JAL,
    output wire JALR,
    output wire Branch
);

  // -------- slicer --------
  assign rd  = instr[11:7];
  assign rs1 = instr[19:15];
  assign rs2 = instr[24:20];

  // -------- coarse decode --------
  wire ALUreg, ALUimm, LUI, AUIPC, Load, Store, SYSTEM;

  decoder #(
      .DATA_WIDTH(DATA_WIDTH)
  ) u_dec (
      .instr   (instr),
      .ALUreg  (ALUreg),
      .regWrite(regWrite),
      .JAL     (JAL),
      .JALR    (JALR),
      .Branch  (Branch),
      .LUI     (LUI),
      .AUIPC   (AUIPC),
      .ALUimm  (ALUimm),
      .Load    (Load),
      .Store   (Store),
      .SYSTEM  (SYSTEM)
  );

  // -------- main control --------
  wire MemtoReg;
  control #(
      .DATA_WIDTH(DATA_WIDTH)
  ) u_ctl (
      .instr (instr),
      .ALUreg(ALUreg),
      .ALUimm(ALUimm),
      .Branch(Branch),
      .JAL   (JAL),
      .JALR  (JALR),
      .LUI   (LUI),
      .AUIPC (AUIPC),
      .Load  (Load),
      .Store (Store),
      .SYSTEM(SYSTEM),

      .MemRead  (MemRead),
      .MemWrite (MemWrite),
      .MemtoReg (MemtoReg),
      .ALUSrc   (ALUSrc),
      .BranchSig(BranchSig),
      .Jump     (Jump),
      .ALUOp    (ALUOp),
      .ImmSrc   (ImmSrc)
  );

  // -------- immediate gen --------
  imm_gen u_imm (
      .instr  (instr),
      .imm_sel(ImmSrc),  // uses `Imm_I/S/B/U/J` from defines.vh
      .imm_out(imm)
  );

  // -------- writeback select (for wb_mux) --------
  assign wb_sel = (JAL | JALR) ? 2'd2 :  // PC+4
      (MemtoReg) ? 2'd1 :  // MEM
      2'd0;  // ALU
endmodule
