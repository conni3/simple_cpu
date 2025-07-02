`timescale 1ns / 1ps

module cpu #(
  parameter DATA_WIDTH = 32,
  parameter ADDR_WIDTH = 11    // 2^11 = 2048 words in IMEM/DMEM
)(
  input  wire                   clk,
  input  wire                   rst
);

  // ----------------------
  // Wires & Busses
  // ----------------------
  // PC and next-PC
  wire [DATA_WIDTH-1:0] pc;
  wire [DATA_WIDTH-1:0] pc_plus4;
  wire [DATA_WIDTH-1:0] branch_pc;
  wire [DATA_WIDTH-1:0] pc_next;

  // Instruction fetch
  wire [DATA_WIDTH-1:0] instr;

  // Control signals
  wire        reg_write;
  wire        mem_read;
  wire        mem_write;
  wire        mem_to_reg;
  wire        branch;
  wire        alu_src;
  wire [1:0]  alu_op;

  // Register file
  wire [4:0]  rs1_addr = instr[19:15];
  wire [4:0]  rs2_addr = instr[24:20];
  wire [4:0]  rd_addr  = instr[11:7];
  wire [DATA_WIDTH-1:0] rs1_data;
  wire [DATA_WIDTH-1:0] rs2_data;
  wire [DATA_WIDTH-1:0] wb_data;

  // Immediate generator
  wire [DATA_WIDTH-1:0] imm;

  // ALU
  wire [3:0]            alu_ctrl;
  wire [DATA_WIDTH-1:0] alu_src2;
  wire [DATA_WIDTH-1:0] alu_result;

  // Data memory
  wire [DATA_WIDTH-1:0] mem_read_data;

  // Branch comparator
  wire                  branch_taken;


  // ----------------------
  // 1) Program Counter
  // ----------------------
  pc #(
    .DATA_WIDTH(DATA_WIDTH)
  ) pc_inst (
    .clk     (clk),
    .rst     (rst),
    .next_pc (pc_next),
    .pc      (pc)
  );

  // PC + 4
  adder #(
    .DATA_WIDTH(DATA_WIDTH)
  ) adder_pc4 (
    .a   (pc),
    .b   (32'd4),
    .sum (pc_plus4)
  );


  // ----------------------
  // 2) Instruction Memory
  // ----------------------
  instr_mem #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  ) imem (
    // drop two LSBs since instructions are word-aligned
    .addr  (pc[ADDR_WIDTH+1:2]),
    .instr (instr)
  );


  // ----------------------
  // 3) Control Unit
  // ----------------------
  control control_inst (
    .opcode     (instr[6:0]),
    .reg_write  (reg_write),
    .mem_read   (mem_read),
    .mem_write  (mem_write),
    .mem_to_reg (mem_to_reg),
    .branch     (branch),
    .alu_src    (alu_src),
    .alu_op     (alu_op)
  );


  // ----------------------
  // 4) Register File
  // ----------------------
  regfile regfile_inst (
    .clk   (clk),
    .we3   (reg_write),
    .ra1   (rs1_addr),
    .ra2   (rs2_addr),
    .wa3   (rd_addr),
    .wd3   (wb_data),
    .rd1   (rs1_data),
    .rd2   (rs2_data)
  );


  // ----------------------
  // 5) Immediate Generator
  // ----------------------
  imm_gen imm_gen_inst (
    .instr   (instr),
    .imm_out (imm)
  );


  // ----------------------
  // 6) ALU Control
  // ----------------------
  alu_control alu_ctrl_inst (
    .funct7    (instr[31:25]),
    .funct3    (instr[14:12]),
    .alu_op    (alu_op),
    .alu_ctrl  (alu_ctrl)
  );


  // ----------------------
  // 7) ALU Operand Mux
  // ----------------------
  mux2 #(
    .WIDTH(DATA_WIDTH)
  ) mux_alu_src (
    .a   (rs2_data),
    .b   (imm),
    .sel (alu_src),
    .y   (alu_src2)
  );

  // ----------------------
  // 8) ALU
  // ----------------------
  alu alu_inst (
    .a         (rs1_data),
    .b         (alu_src2),
    .alu_ctrl  (alu_ctrl),
    .result    (alu_result)
  );


  // ----------------------
  // 9) Data Memory
  // ----------------------
  data_mem #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  ) dmem (
    .clk  (clk),
    .we   (mem_write),
    .re   (mem_read),
    .addr (alu_result[ADDR_WIDTH-1:0]),
    .wd   (rs2_data),
    .rd   (mem_read_data)
  );


  // ----------------------
  // 10) Write-Back Mux
  // ----------------------
  mux2 #(
    .WIDTH(DATA_WIDTH)
  ) mux_wb (
    .a   (alu_result),
    .b   (mem_read_data),
    .sel (mem_to_reg),
    .y   (wb_data)
  );


  // ----------------------
  // 11) Branch Target Adder
  // ----------------------
  adder #(
    .DATA_WIDTH(DATA_WIDTH)
  ) adder_branch (
    .a   (pc),
    .b   (imm),
    .sum (branch_pc)
  );

  // ----------------------
  // 12) Branch Comparator
  // ----------------------
  branch_comp branch_comp_inst (
    .a         (rs1_data),
    .b         (rs2_data),
    .branch    (branch),
    .comp_out  (branch_taken)
  );

  // ----------------------
  // 13) PC Mux (branch or PC+4)
  // ----------------------
  mux2 #(
    .WIDTH(DATA_WIDTH)
  ) mux_pc (
    .a   (pc_plus4),
    .b   (branch_pc),
    .sel (branch_taken),
    .y   (pc_next)
  );

endmodule
