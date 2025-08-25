`timescale 1ps / 1ps
`include "defines.vh"

module datapath #(
    parameter integer DATA_WIDTH = `DATA_WIDTH,
    parameter integer ADDR_WIDTH = `ADDR_WIDTH,
    parameter IMEM_FILE = "src/instr_mem.mem",
    parameter DMEM_FILE = "src/data_mem.mem"
) (
    input wire clk,
    input wire reset,


    input wire [ 6:0] opcode,
    input wire [ 4:0] rd,
    input wire [ 2:0] funct3,
    input wire [ 4:0] rs1,
    input wire [ 4:0] rs2,
    input wire [ 6:0] funct7,
    input wire [19:0] csr,

    input wire [ 3:0] alu_ctrl,
    input wire [31:0] imm_out,
    input wire        reg_write,
    input wire        mem_read,
    input wire        mem_write,
    input wire        alu_src,
    input wire [ 1:0] op1_sel,
    input wire [ 1:0] wb_sel,

    input wire is_branch,
    input wire is_jal,
    input wire is_jalr,


    output wire [31:0] instr,
    output wire [31:0] debug_pc,
    output wire [31:0] debug_alu
);


  wire branch_taken;
  wire [31:0] rs1_data, rs2_data;
  wire [31:0] pc_current, pc_next, pc_plus4;
  wire [31:0] alu_result;
  wire        alu_zero;
  wire [31:0] rdata;
  wire [31:0] op_a, op_b;
  wire [31:0] wb_data;


  wire [ADDR_WIDTH-1:0] imem_addr = pc_current[ADDR_WIDTH+1:2];
  wire [ADDR_WIDTH-1:0] dmem_addr = alu_result[ADDR_WIDTH+1:2];


  branch_comp u_branch_comp (
      .op1         (rs1_data),
      .op2         (rs2_data),
      .funct3      (funct3),
      .branch_taken(branch_taken)
  );


  next_pc u_next_pc (
      .pc_current  (pc_current),
      .imm_out     (imm_out),
      .rs1_data    (rs1_data),
      .is_branch   (is_branch),
      .is_jal      (is_jal),
      .is_jalr     (is_jalr),
      .branch_taken(branch_taken),
      .pc_next     (pc_next)
  );


  pc u_pc (
      .clk       (clk),
      .reset     (reset),
      .next_pc   (pc_next),
      .current_pc(pc_current)
  );

  assign pc_plus4 = pc_current + 32'd4;
  assign debug_pc = pc_current;


  (* DONT_TOUCH = "true" *) regfile u_rf (
      .clk      (clk),
      .reset    (reset),
      .rs1      (rs1),
      .rs2      (rs2),
      .rd       (rd),
      .rd_wdata (wb_data),
      .reg_write(reg_write),
      .rs1_data (rs1_data),
      .rs2_data (rs2_data)
  );


  assign op_a = (op1_sel == `OP1_RS1) ? rs1_data : (op1_sel == `OP1_PC) ? pc_current : 32'b0;

  assign op_b = (alu_src) ? imm_out : rs2_data;


  (* DONT_TOUCH = "true" *) alu u_alu (
      .op_a      (op_a),
      .op_b      (op_b),
      .alu_ctrl  (alu_ctrl),
      .alu_result(alu_result),
      .alu_zero  (alu_zero)
  );


  (* DONT_TOUCH = "true" *) instr_mem #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .MEM_FILE  (IMEM_FILE)
  ) u_imem (
      .addr (imem_addr),
      .instr(instr)
  );


  (* DONT_TOUCH = "true" *) data_mem #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .MEM_FILE  (DMEM_FILE)
  ) u_dmem (
      .clk      (clk),
      .mem_read (mem_read),
      .mem_write(mem_write),
      .addr     (dmem_addr),
      .wdata    (rs2_data),
      .rdata    (rdata)
  );


  assign wb_data =
      (wb_sel == `WB_ALU) ? alu_result :
      (wb_sel == `WB_MEM) ? rdata      :
      (wb_sel == `WB_PC4) ? pc_plus4   :
                            32'b0;

  assign debug_alu = alu_result;

endmodule
