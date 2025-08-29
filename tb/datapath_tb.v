`timescale 1ps / 1ps
`include "defines.vh"

module datapath_tb;
  reg clk = 1'b0;
  reg reset = 1'b1;
  always #5 clk = ~clk;
  reg  [31:0] pc_before;
  reg  [31:0] pc_after;

  reg  [ 6:0] opcode;
  reg  [ 4:0] rd;
  reg  [ 2:0] funct3;
  reg  [ 4:0] rs1;
  reg  [ 4:0] rs2;
  reg  [ 6:0] funct7;
  reg  [19:0] csr;

  reg  [ 3:0] alu_ctrl;
  reg  [31:0] imm_out;
  reg         reg_write;
  reg         mem_read;
  reg         mem_write;
  reg         alu_src;
  reg  [ 1:0] op1_sel;
  reg  [ 1:0] wb_sel;

  reg         is_branch;
  reg         is_jal;
  reg         is_jalr;

  wire [31:0] instr;

  datapath uut (
      .clk  (clk),
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

      .instr(instr)
  );




  integer passed, failed;

  task init_controls;
    begin
      opcode    = 7'd0;
      rd        = 5'd0;
      funct3    = 3'd0;
      rs1       = 5'd0;
      rs2       = 5'd0;
      funct7    = 7'd0;
      csr       = 20'd0;

      alu_ctrl  = `ALU_ADD;
      imm_out   = 32'd0;
      reg_write = 1'b0;
      mem_read  = 1'b0;
      mem_write = 1'b0;
      alu_src   = 1'b0;
      op1_sel   = `OP1_RS1;
      wb_sel    = `WB_ALU;

      is_branch = 1'b0;
      is_jal    = 1'b0;
      is_jalr   = 1'b0;
    end
  endtask

  task step;
    begin
      @(posedge clk);
      #1;
    end
  endtask

  task chk;
    input cond;
    input [255:0] msg;
    begin
      if (!cond) begin
        $display("FAIL: %0s  t=%0t", msg, $time);
        failed = failed + 1;
      end else begin
        $display("PASS: %0s  t=%0t", msg, $time);
        passed = passed + 1;
      end
    end
  endtask





  function [31:0] peek_reg;
    input [4:0] idx;
    begin

      peek_reg = uut.u_rf.regs[idx];
    end
  endfunction

  function [31:0] peek_dmem_word;
    input [31:0] byte_addr;
    reg [31:0] word_idx;
    begin

      word_idx = byte_addr[31:2];
      peek_dmem_word = uut.u_dmem.mem[word_idx];
    end
  endfunction




  initial begin
    passed = 0;
    failed = 0;

    $dumpfile("dump.vcd");
    $dumpvars(0, datapath_tb);


    init_controls();
    reset = 1'b1;
    repeat (2) step();
    reset = 1'b0;
    step();




    init_controls();
    rs1       = 5'd0;
    rd        = 5'd5;
    alu_ctrl  = `ALU_ADD;
    alu_src   = 1'b1;
    imm_out   = 32'd123;
    op1_sel   = `OP1_RS1;
    wb_sel    = `WB_ALU;
    reg_write = 1'b1;
    step();


    init_controls();
    step();

    chk(peek_reg(5) == 32'd123, "x5 = 123 via ALU/WB_ALU");




    init_controls();
    rs1       = 5'd0;
    rs2       = 5'd5;
    alu_ctrl  = `ALU_ADD;
    alu_src   = 1'b1;
    imm_out   = 32'h0000_0010;
    op1_sel   = `OP1_RS1;
    mem_write = 1'b1;
    step();


    init_controls();
    step();

    chk(peek_dmem_word(32'h10) == 32'd123, "DMEM[0x10] = 123 after store");



    init_controls();
    rs1       = 5'd0;
    rd        = 5'd6;
    alu_ctrl  = `ALU_ADD;
    alu_src   = 1'b1;
    imm_out   = 32'h0000_0010;
    op1_sel   = `OP1_RS1;
    mem_read  = 1'b1;
    wb_sel    = `WB_MEM;
    reg_write = 1'b1;
    step();


    init_controls();
    step();

    chk(peek_reg(6) == 32'd123, "x6 = 123 via load/WB_MEM");




    init_controls();
    rs1       = 5'd6;
    rs2       = 5'd6;
    funct3    = 3'b000;
    is_branch = 1'b1;

    step();




    init_controls();
    rs1       = 5'd5;
    rd        = 5'd7;
    alu_ctrl  = `ALU_ADD;
    alu_src   = 1'b1;
    imm_out   = 32'd7;
    op1_sel   = `OP1_RS1;
    wb_sel    = `WB_ALU;
    reg_write = 1'b1;
    step();
    init_controls();
    step();
    chk(peek_reg(7) == 32'd130, "ALU ADDI: x7 = 130");


    init_controls();
    rs1       = 5'd7;
    rs2       = 5'd5;
    rd        = 5'd8;
    alu_ctrl  = `ALU_SUB;
    alu_src   = 1'b0;
    op1_sel   = `OP1_RS1;
    wb_sel    = `WB_ALU;
    reg_write = 1'b1;
    step();
    init_controls();
    step();
    chk(peek_reg(8) == 32'd7, "ALU SUB: x8 = 7");


    init_controls();
    rs1       = 5'd5;
    rd        = 5'd9;
    alu_ctrl  = `ALU_AND;
    alu_src   = 1'b1;
    imm_out   = 32'h0000_000F;
    op1_sel   = `OP1_RS1;
    wb_sel    = `WB_ALU;
    reg_write = 1'b1;
    step();
    init_controls();
    step();
    chk(peek_reg(9) == 32'd11, "ALU ANDI: x9 = 11");


    init_controls();
    rs1       = 5'd5;
    rd        = 5'd10;
    alu_ctrl  = `ALU_SLL;
    alu_src   = 1'b1;
    imm_out   = 32'd2;
    op1_sel   = `OP1_RS1;
    wb_sel    = `WB_ALU;
    reg_write = 1'b1;
    step();
    init_controls();
    step();
    chk(peek_reg(10) == (32'd123 << 2), "ALU SLLI: x10 = 492");


    init_controls();
    rs1       = 5'd10;
    rd        = 5'd11;
    alu_ctrl  = `ALU_SRL;
    alu_src   = 1'b1;
    imm_out   = 32'd1;
    op1_sel   = `OP1_RS1;
    wb_sel    = `WB_ALU;
    reg_write = 1'b1;
    step();
    init_controls();
    step();
    chk(peek_reg(11) == (32'd492 >> 1), "ALU SRLI: x11 = 246");


    init_controls();
    rs1       = 5'd0;
    rd        = 5'd12;
    alu_ctrl  = `ALU_ADD;
    alu_src   = 1'b1;
    imm_out   = 32'hFFFF_FF80;
    op1_sel   = `OP1_RS1;
    wb_sel    = `WB_ALU;
    reg_write = 1'b1;
    step();
    init_controls();
    step();
    chk($signed(peek_reg(12)) == -128, "Prep: x12 = -128");


    init_controls();
    rs1       = 5'd12;
    rd        = 5'd13;
    alu_ctrl  = `ALU_SRA;
    alu_src   = 1'b1;
    imm_out   = 32'd2;
    op1_sel   = `OP1_RS1;
    wb_sel    = `WB_ALU;
    reg_write = 1'b1;
    step();
    init_controls();
    step();
    chk(peek_reg(13) == 32'hFFFF_FFE0, "ALU SRAI: x13 = 0xFFFF_FFE0");



    init_controls();

    pc_before = uut.pc_current;
    step();
    init_controls();
    step();
    pc_after = uut.pc_current;
    chk(pc_after == pc_before + 32'd8, "PC advanced by two cycles of +4");


    init_controls();
    rs1       = 5'd6;
    rs2       = 5'd6;
    funct3    = 3'b000;
    is_branch = 1'b1;
    imm_out   = 32'd16;
    pc_before = uut.pc_current;
    step();
    init_controls();
    step();
    pc_after = uut.pc_current;
    chk(pc_after == (pc_before + 32'd16 + 32'd4), "BEQ taken: PC jumped by imm (+ one +4)");


    // BNE NOT TAKEN (fall-through by +8 over two cycles)
    init_controls();
    rs1       = 5'd5;
    rs2       = 5'd5;  // <-- was 5'd7
    funct3    = 3'b001;  // BNE
    is_branch = 1'b1;
    imm_out   = 32'd24;
    pc_before = uut.pc_current;
    step();
    init_controls();
    step();
    pc_after = uut.pc_current;
    chk(pc_after == pc_before + 32'd8, "BNE not taken: PC advanced by +8 over two cycles");



    init_controls();
    rd        = 5'd1;
    wb_sel    = `WB_PC4;
    reg_write = 1'b1;
    is_jal    = 1'b1;
    imm_out   = 32'd40;
    pc_before = uut.pc_current;
    step();
    init_controls();
    step();
    pc_after = uut.pc_current;
    chk(peek_reg(1) == (pc_before + 32'd4), "JAL: x1 <= PC+4");
    chk(pc_after == (pc_before + 32'd40 + 32'd4), "JAL: PC jumped by imm (+ one +4)");




    init_controls();
    rd        = 5'd2;
    rs1       = 5'd5;
    imm_out   = 32'd8;
    wb_sel    = `WB_PC4;
    reg_write = 1'b1;
    is_jalr   = 1'b1;
    pc_before = uut.pc_current;
    step();
    init_controls();
    step();
    pc_after = uut.pc_current;
    chk(peek_reg(2) == (pc_before + 32'd4), "JALR: rd <= PC+4");
    chk(pc_after == ((32'd123 + 32'd8) & 32'hFFFF_FFFE) + 32'd4,
        "JALR: PC = (rs1+imm)&~1 (+ one +4)");


    $display("RESULT: passed=%0d failed=%0d", passed, failed);
    if (failed == 0) $display("ALL TESTS PASSED.");
    else $display("SOME TESTS FAILED.");
    $finish;
  end

endmodule
