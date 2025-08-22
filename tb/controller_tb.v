`timescale 1ns / 1ps
`include "defines.vh"

module controller_tb;

  // ----------------------------
  // DUT I/O
  // ----------------------------
  reg  [31:0] instr;

  wire [ 6:0] opcode;
  wire [4:0] rd, rs1, rs2;
  wire [ 2:0] funct3;
  wire [ 6:0] funct7;
  wire [19:0] csr;

  wire [ 3:0] alu_ctrl;
  wire [31:0] imm_out;
  wire reg_write, mem_read, mem_write;
  wire alu_src;
  wire [1:0] wb_sel;  // 00:ALU, 01:MEM, 10:PC+4
  wire [1:0] op1_sel;  // 00:RS1, 01:PC, 10:ZERO
  wire is_branch, is_jal, is_jalr;

  controller dut (
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

  // ----------------------------
  // Encoders
  // ----------------------------
  function [31:0] rtype;
    input [6:0] f7;
    input [4:0] rs2_i, rs1_i;
    input [2:0] f3;
    input [4:0] rd_i;
    input [6:0] opc;
    begin
      rtype = {f7, rs2_i, rs1_i, f3, rd_i, opc};
    end
  endfunction

  function [31:0] itype;  // I-type (ADDI/ANDI/SLLI/.., JALR, LOADs shape)
    input integer imm12;
    input [4:0] rs1_i;
    input [2:0] f3;
    input [4:0] rd_i;
    input [6:0] opc;
    reg [11:0] u;
    begin
      u = imm12[11:0];
      itype = {u, rs1_i, f3, rd_i, opc};
    end
  endfunction

  function [31:0] store;  // S-type
    input integer imm12;
    input [4:0] rs2_i, rs1_i;
    input [2:0] f3;
    reg [11:0] u;
    begin
      u = imm12[11:0];
      store = {u[11:5], rs2_i, rs1_i, f3, u[4:0], `OP_STORE};
    end
  endfunction

  function [31:0] branch;  // B-type (imm13 with LSB zero)
    input integer imm13;
    input [4:0] rs2_i, rs1_i;
    input [2:0] f3;
    reg [12:0] b;
    begin
      b = imm13[12:0];
      branch = {b[12], b[10:5], rs2_i, rs1_i, f3, b[4:1], b[11], `OP_BRANCH};
    end
  endfunction

  function [31:0] utype;  // U-type (LUI/AUIPC)
    input [19:0] imm20;
    input [4:0] rd_i;
    input [6:0] opc;
    begin
      utype = {imm20, rd_i, opc};
    end
  endfunction

  function [31:0] jtype;  // J-type (JAL; imm21 with LSB zero)
    input integer imm21;
    input [4:0] rd_i;
    reg [20:0] j;
    begin
      j = imm21[20:0];
      jtype = {j[20], j[10:1], j[11], j[19:12], rd_i, `OP_JAL};
    end
  endfunction

  // ----------------------------
  // Pass/Fail counters
  // ----------------------------
  integer pass_cnt, fail_cnt, total_cnt;

  task note_pass;
    begin
      pass_cnt  = pass_cnt + 1;
      total_cnt = total_cnt + 1;
    end
  endtask
  task note_fail;
    begin
      fail_cnt  = fail_cnt + 1;
      total_cnt = total_cnt + 1;
    end
  endtask

  // ----------------------------
  // Check helpers
  // ----------------------------
  task expect_eq32;
    input [1023:0] name;
    input [31:0] got, exp;
    begin
      if (got !== exp) begin
        $display("FAIL: %0s got=0x%08x exp=0x%08x", name, got, exp);
        note_fail();
      end else note_pass();
    end
  endtask

  task expect_bits;
    input [1023:0] name;
    input got, exp;
    begin
      if (got !== exp) begin
        $display("FAIL: %0s got=%0d exp=%0d", name, got, exp);
        note_fail();
      end else note_pass();
    end
  endtask

  task expect_small;
    input [1023:0] name;
    input [7:0] got, exp;
    begin
      if (got !== exp) begin
        $display("FAIL: %0s got=%0d exp=%0d", name, got, exp);
        note_fail();
      end else note_pass();
    end
  endtask

  // ----------------------------
  // Stimulus
  // ----------------------------
  integer percent;
  initial begin
    pass_cnt = 0;
    fail_cnt = 0;
    total_cnt = 0;

    // 1) ADD
    instr = rtype(7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, `OP_RTYPE);
    #1;
    expect_bits("reg_write ADD", reg_write, 1);
    expect_bits("mem_read ADD", mem_read, 0);
    expect_bits("mem_write ADD", mem_write, 0);
    expect_small("alu_src ADD", {6'b0, alu_src}, 2'b00);
    expect_small("wb_sel ADD", {6'b0, wb_sel}, 2'b00);
    expect_small("alu_ctrl ADD", {4'b0, alu_ctrl}, `ALU_ADD);
    expect_small("op1_sel ADD", {6'b0, op1_sel}, 2'b00);

    // 2) SUB
    instr = rtype(7'b0100000, 5'd2, 5'd1, 3'b000, 5'd3, `OP_RTYPE);
    #1;
    expect_small("alu_ctrl SUB", {4'b0, alu_ctrl}, `ALU_SUB);
    expect_small("op1_sel ADD", {6'b0, op1_sel}, 2'b00);

    // 3) ANDI
    instr = itype(-1, 5'd1, 3'b111, 5'd5, `OP_ITYPE);
    #1;
    expect_bits("reg_write ANDI", reg_write, 1);
    expect_small("alu_src ANDI", {6'b0, alu_src}, 2'b01);
    expect_small("wb_sel ANDI", {6'b0, wb_sel}, 2'b00);
    expect_small("alu_ctrl ANDI", {4'b0, alu_ctrl}, `ALU_AND);
    expect_eq32("imm_out ANDI", imm_out, 32'hFFFFFFFF);
    expect_small("op1_sel ANDI", {6'b0, op1_sel}, 2'b00);

    // 4) SLLI (shamt=3)
    instr = itype(3, 5'd1, 3'b001, 5'd5, `OP_ITYPE);
    #1;
    expect_small("alu_ctrl SLLI", {4'b0, alu_ctrl}, `ALU_SLL);
    expect_small("alu_src SLLI", {6'b0, alu_src}, 2'b01);
    expect_eq32("imm_out SLLI", imm_out, 32'd3);
    expect_small("op1_sel SLLI", {6'b0, op1_sel}, 2'b00);

    // 5) SRLI (imm[11:5]=0000000)
    instr = itype(1, 5'd1, 3'b101, 5'd5, `OP_ITYPE);
    #1;
    expect_small("alu_ctrl SRLI", {4'b0, alu_ctrl}, `ALU_SRL);
    expect_small("op1_sel SRLI", {6'b0, op1_sel}, 2'b00);

    // 6) SRAI (imm=12'h401 -> 0100000|00001)
    instr = itype(12'h401, 5'd1, 3'b101, 5'd5, `OP_ITYPE);
    #1;
    expect_small("alu_ctrl SRAI", {4'b0, alu_ctrl}, `ALU_SRA);
    expect_small("op1_sel SRAI", {6'b0, op1_sel}, 2'b00);

    // 7) OR (R-type)
    instr = rtype(7'b0000000, 5'd2, 5'd1, 3'b110, 5'd3, `OP_RTYPE);
    #1;
    expect_small("alu_ctrl OR", {4'b0, alu_ctrl}, `ALU_OR);
    expect_small("op1_sel OR", {6'b0, op1_sel}, 2'b00);

    // 8) XORI
    instr = itype(7'h7F, 5'd1, 3'b100, 5'd3, `OP_ITYPE);
    #1;
    expect_small("alu_ctrl XORI", {4'b0, alu_ctrl}, `ALU_XOR);
    expect_small("op1_sel XORI", {6'b0, op1_sel}, 2'b00);

    // 9) ADDI -8
    instr = itype(-8, 5'd1, 3'b000, 5'd5, `OP_ITYPE);
    #1;
    expect_small("alu_ctrl ADDI", {4'b0, alu_ctrl}, `ALU_ADD);
    expect_eq32("imm_out ADDI", imm_out, 32'hFFFFFFF8);
    expect_small("op1_sel ADDI", {6'b0, op1_sel}, 2'b00);

    // 10) LW
    instr = itype(16, 5'd1, 3'b010, 5'd7, `OP_LOAD);
    #1;
    expect_bits("mem_read LW", mem_read, 1);
    expect_bits("mem_write LW", mem_write, 0);
    expect_bits("reg_write LW", reg_write, 1);
    expect_small("alu_src LW", {6'b0, alu_src}, 2'b01);
    expect_small("wb_sel LW", {6'b0, wb_sel}, 2'b01);
    expect_small("alu_ctrl LW", {4'b0, alu_ctrl}, `ALU_ADD);
    expect_small("op1_sel LW", {6'b0, op1_sel}, 2'b00);

    // 11) SW
    instr = store(-16, 5'd7, 5'd1, 3'b010);
    #1;
    expect_bits("mem_read SW", mem_read, 0);
    expect_bits("mem_write SW", mem_write, 1);
    expect_bits("reg_write SW", reg_write, 0);
    expect_small("alu_src SW", {6'b0, alu_src}, 2'b01);
    expect_small("alu_ctrl SW", {4'b0, alu_ctrl}, `ALU_ADD);
    expect_small("op1_sel SW", {6'b0, op1_sel}, 2'b00);

    // 12) BEQ
    instr = branch(13'd8, 5'd2, 5'd1, 3'b000);
    #1;
    expect_bits("is_branch BEQ", is_branch, 1);
    expect_bits("reg_write BEQ", reg_write, 0);
    expect_small("op1_sel BEQ", {6'b0, op1_sel}, 2'b00);

    // 13) JAL
    instr = jtype(21'd20, 5'd1);
    #1;
    expect_bits("is_jal JAL", is_jal, 1);
    expect_bits("is_jalr JAL", is_jalr, 0);
    expect_small("wb_sel JAL", {6'b0, wb_sel}, 2'b10);
    expect_bits("reg_write JAL", reg_write, 1);
    expect_small("op1_sel JAL", {6'b0, op1_sel}, 2'b01);

    // 14) JALR
    instr = itype(0, 5'd2, 3'b000, 5'd1, `OP_JALR);
    #1;
    expect_bits("is_jal JALR", is_jal, 0);
    expect_bits("is_jalr JALR", is_jalr, 1);
    expect_small("wb_sel JALR", {6'b0, wb_sel}, 2'b10);
    expect_bits("reg_write JALR", reg_write, 1);
    expect_small("op1_sel JALR", {6'b0, op1_sel}, 2'b00);

    // 15) LUI
    instr = utype(20'h12345, 5'd10, `OP_LUI);
    #1;
    expect_bits("reg_write LUI", reg_write, 1);
    expect_small("alu_ctrl LUI", {4'b0, alu_ctrl}, `ALU_ADD);
    expect_small("wb_sel LUI", {6'b0, wb_sel}, 2'b00);
    expect_eq32("imm_out LUI", imm_out, 32'h12345000);
    expect_small("op1_sel LUI", {6'b0, op1_sel}, 2'b10);

    // 16) AUIPC (no strict asserts beyond reg_write)
    instr = utype(20'h00010, 5'd11, `OP_AUIPC);
    #1;
    expect_bits("reg_write AUIPC", reg_write, 1);
    expect_small("op1_sel AUIPC", {6'b0, op1_sel}, 2'b01);
    expect_eq32("imm_out AUIPC", imm_out, 32'h00010000);
    expect_small("op1_sel AUIPC", {6'b0, op1_sel}, 2'b01);

    // ----------------------------
    // Summary (integer percent)
    // ----------------------------
    if (total_cnt == 0) percent = 0;
    else percent = (pass_cnt * 100) / total_cnt;

    $display("\n================ TEST SUMMARY ================");
    $display("  Total checks : %0d", total_cnt);
    $display("  Passed       : %0d", pass_cnt);
    $display("  Failed       : %0d", fail_cnt);
    $display("  Pass rate    : %0d%%", percent);
    if (fail_cnt == 0) $display("  RESULT       : ALL TESTS PASSED");
    else $display("  RESULT       : TESTS FAILED");
    $display("==============================================\n");

    $finish;
  end

endmodule
