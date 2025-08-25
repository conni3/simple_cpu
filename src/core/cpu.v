`timescale 1ps / 1ps
`include "defines.vh"

module cpu #(
    parameter integer DATA_WIDTH = 32,
    parameter integer ADDR_WIDTH = `ADDR_WIDTH,
    parameter         IMEM_FILE  = "src/instr_mem.mem",
    parameter         DMEM_FILE  = "src/data_mem.mem"
) (
    input wire clk,
    input wire reset,
    output wire [31:0] debug_pc,
    output wire [31:0] debug_instr,
    output wire [31:0] debug_alu
);


  (* KEEP = "true" *) wire [31:0] instr;
  (* KEEP = "true" *) wire [31:0] debug_alu_int;
  wire [ 6:0] opcode;
  wire [4:0] rd, rs1, rs2;
  wire [ 2:0] funct3;
  wire [ 6:0] funct7;
  wire [19:0] csr;
  wire [ 3:0] alu_ctrl;
  wire [31:0] imm_out;
  wire reg_write, mem_read, mem_write, alu_src;
  wire [1:0] op1_sel, wb_sel;
  wire is_branch, is_jal, is_jalr;

  (* DONT_TOUCH = "true" *) controller u_controller (
      .instr(instr),
      .opcode(opcode),
      .rd(rd),
      .funct3(funct3),
      .rs1(rs1),
      .rs2(rs2),
      .funct7(funct7),
      .csr(csr),
      .alu_ctrl(alu_ctrl),
      .imm_out(imm_out),
      .reg_write(reg_write),
      .mem_read(mem_read),
      .mem_write(mem_write),
      .alu_src(alu_src),
      .op1_sel(op1_sel),
      .wb_sel(wb_sel),
      .is_branch(is_branch),
      .is_jal(is_jal),
      .is_jalr(is_jalr)
  );

  (* DONT_TOUCH = "true" *) datapath #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH),
      .IMEM_FILE (IMEM_FILE),
      .DMEM_FILE (DMEM_FILE)
  ) u_datapath (
      .clk(clk),
      .reset(reset),
      .opcode(opcode),
      .rd(rd),
      .funct3(funct3),
      .rs1(rs1),
      .rs2(rs2),
      .funct7(funct7),
      .csr(csr),
      .alu_ctrl(alu_ctrl),
      .imm_out(imm_out),
      .reg_write(reg_write),
      .mem_read(mem_read),
      .mem_write(mem_write),
      .alu_src(alu_src),
      .op1_sel(op1_sel),
      .wb_sel(wb_sel),
      .is_branch(is_branch),
      .is_jal(is_jal),
      .is_jalr(is_jalr),
      .instr(instr),
      .debug_pc(debug_pc),
      .debug_alu(debug_alu_int)
  );

  assign debug_instr = instr;
  assign debug_alu   = debug_alu_int;

endmodule
