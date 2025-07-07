`timescale 1ns / 1ps
`include "include/defines.vh"

module cpu (
    input wire clk,
    input wire reset
);
  // Parameters
  localparam DATA_W = 32;
  localparam ADDR_W = 11;

  // PCs
  wire [31:0] current_pc;
  wire [31:0] pc_plus4;
  wire [31:0] branch_pc;
  wire [31:0] next_pc;


  // Instruction
  reg [31:0] current_instr;
  reg [6:0] opcode = current_instr[6:0];
  reg [2:0] funct3 = current_instr[14:12];
  reg [6:0] funct7 = current_instr[31:25];
  reg [4:0] rs1 = current_instr[19:15];
  reg [4:0] rs2 = current_instr[24:20];
  reg [4:0] rd = current_instr[11:7];


  // Control signals
  reg RegWrite;
  reg MemRead;
  reg MemWrite;
  reg MemtoReg;
  reg ALUSrc;
  reg Branch;
  reg Jump;
  reg [1:0] ALUOp;
  reg [2:0] ImmSrc;

  // Branching
  reg BranchTaken;
  assign PCsrc = Branch & BranchTaken;


  reg [31:0] rs1_data;
  reg [31:0] rs2_data;
  reg [31:0] imm_data;

  // alu
  reg [3:0] ALUControl;
  reg ALUZero;
  reg [31:0] ALUResult;

  // mem
  reg [31:0] mem_data;

  // fetch
  pc pc_inst (
      .clk(clk),
      .reset(reset),
      .next_pc(next_pc),
      .current_pc(current_pc)
  );

  adder #(
      .WIDTH(32)
  ) pc_plus4_inst (
      .a(current_pc),
      .b(32'd4),
      .result(pc_plus4)
  );

  mux2 #(
      .WIDTH(32)
  ) pc_mux_inst (
      .sel(PCsrc),
      .b  (pc_plus4),
      .a  (branch_pc),
      .y  (next_pc)
  );

  instr_mem instr_mem_inst (
      .addr (next_pc[12:2]),
      .instr(current_instr)
  );

  // decode
  control control_inst (
      .opcode(opcode),
      .funct3(funct3),
      .RegWrite(RegWrite),
      .MemRead(MemRead),
      .MemWrite(MemWrite),
      .MemtoReg(MemtoReg),
      .ALUSrc(ALUSrc),
      .Branch(Branch),
      .Jump(Jump),
      .ALUOp(ALUOp),
      .ImmSrc(ImmSrc)
  );

  imm_gen imm_gen_inst (
      .instr  (current_instr),
      .imm_sel(ImmSrc),
      .imm_out(imm_data)
  );



  // execute 
  branch_comp branch_comp_inst (
      .op1(rs1_data),
      .op2(rs2_data),
      .funct3(funct3),
      .branch(BranchTaken)
  );

  alu_control alu_control_inst (
      .ALUOp(ALUOp),
      .funct3(funct3),
      .funct7_5(funct7[5]),
      .ALUCtrl(ALUControl)
  );

  alu alu_inst (
      .operand_a(rs1_data),
      .operand_b(ALUSrc ? imm_data : rs2_data),
      .alu_control(ALUControl),
      .alu_result(ALUResult),
      .zero(ALUZero)
  );

  wire [31:0] branch_target;
  adder #(
      .WIDTH(32)
  ) branch_adder (
      .a(current_pc),
      .b(imm_data),
      .result(branch_target)
  );

  // memory
  data_mem data_mem_inst (
      .clk(clk),
      .re(MemRead),
      .we(MemWrite),
      .addr(ALUResult[10:0]),
      .write_data(rs2_data),
      .read_data(mem_data)
  );

  // write back

  reg_file reg_file_inst (
      .clk(clk),
      .reset(reset),
      .regwrite(RegWrite),
      .read_reg1(rs1),
      .read_reg2(rs2),
      .write_reg(rd),
      .write_data(MemtoReg ? mem_data : ALUResult),
      .read_data1(rs1_data),
      .read_data2(rs2_data)
  );


endmodule
