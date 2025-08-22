`timescale 1ns / 1ps
`include "defines.vh"

module control_tb;

  // ---- Optional (keeps TB self-contained if not defined in defines.vh) ----
  localparam [1:0] OP1_RS1 = 2'd0;
  localparam [1:0] OP1_PC = 2'd1;
  localparam [1:0] OP1_ZERO = 2'd2;

  // ---- DUT I/O ----
  reg [31:0] instr;

  // one-hot class flags (as driven by your decoder)
  reg
      is_alu_reg,
      is_alu_imm,
      is_branch,
      is_jal,
      is_jalr,
      is_lui,
      is_auipc,
      is_load,
      is_store,
      is_system;

  wire mem_read, mem_write;
  wire alu_src, branch_sig, jump;
  wire [1:0] alu_op;
  wire [2:0] imm_sel;
  wire [1:0] wb_sel;
  wire [1:0] op1_sel;

  control dut (
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
      .alu_src   (alu_src),
      .branch_sig(branch_sig),
      .jump      (jump),
      .alu_op    (alu_op),
      .imm_sel   (imm_sel),
      .wb_sel    (wb_sel),
      .op1_sel   (op1_sel)
  );

  integer passed, failed;

  // ---- Helpers ----
  task reset_inputs;
    begin
      {is_alu_reg, is_alu_imm, is_branch, is_jal, is_jalr, is_lui, is_auipc, is_load, is_store, is_system} = 10'b0;
      instr = 32'b0;
    end
  endtask

  // Single place to check all control outputs (now checks op1_sel too)
  task expect_ctrl;
    input exp_mem_read, exp_mem_write;
    input exp_alu_src, exp_branch_sig, exp_jump;
    input [1:0] exp_alu_op;
    input [2:0] exp_imm_sel;
    input [1:0] exp_wb_sel;
    input [1:0] exp_op1_sel;
    input [8*64-1:0] label;
    begin
      #1;
      if (mem_read   !== exp_mem_read   ||
          mem_write  !== exp_mem_write  ||
          alu_src    !== exp_alu_src    ||
          branch_sig !== exp_branch_sig ||
          jump       !== exp_jump       ||
          alu_op     !== exp_alu_op     ||
          imm_sel    !== exp_imm_sel    ||
          wb_sel     !== exp_wb_sel     ||
          op1_sel    !== exp_op1_sel) begin
        $display("FAIL [%0s] t=%0t", label, $time);
        $display("  Got     : mr=%b mw=%b as=%b br=%b j=%b alu=%02b imm=%03b wb=%02b op1=%02b",
                 mem_read, mem_write, alu_src, branch_sig, jump, alu_op, imm_sel, wb_sel, op1_sel);
        $display("  Expect  : mr=%b mw=%b as=%b br=%b j=%b alu=%02b imm=%03b wb=%02b op1=%02b",
                 exp_mem_read, exp_mem_write, exp_alu_src, exp_branch_sig, exp_jump, exp_alu_op,
                 exp_imm_sel, exp_wb_sel, exp_op1_sel);
        failed = failed + 1;
      end else begin
        $display("PASS [%0s]", label);
        passed = passed + 1;
      end
    end
  endtask

  // ---- Encoders (Verilog-2001) ----
  function [31:0] enc_i;  // I-type (ADDI/… , JALR, LOAD)
    input [11:0] imm12;
    input [4:0] rs1;
    input [2:0] f3;
    input [4:0] rd;
    input [6:0] opc;
    begin
      enc_i = {imm12, rs1, f3, rd, opc};
    end
  endfunction

  function [31:0] enc_s;  // S-type (STORE)
    input [11:0] imm12;
    input [4:0] rs2;
    input [4:0] rs1;
    input [2:0] f3;
    input [6:0] opc;
    begin
      enc_s = {imm12[11:5], rs2, rs1, f3, imm12[4:0], opc};
    end
  endfunction

  function [31:0] enc_b;  // B-type (BRANCH)
    input [12:0] imm13;  // imm[0]=0
    input [4:0] rs2;
    input [4:0] rs1;
    input [2:0] f3;
    input [6:0] opc;
    reg [31:0] t;
    begin
      t[31]    = imm13[12];
      t[7]     = imm13[11];
      t[30:25] = imm13[10:5];
      t[11:8]  = imm13[4:1];
      t[6:0]   = opc;
      t[24:20] = rs2;
      t[19:15] = rs1;
      t[14:12] = f3;
      t[11:7]  = 5'b00000;
      enc_b    = t;
    end
  endfunction

  function [31:0] enc_u;  // U-type (LUI/AUIPC)
    input [19:0] imm20;
    input [4:0] rd;
    input [6:0] opc;
    begin
      enc_u = {imm20, rd, opc};
    end
  endfunction

  function [31:0] enc_j;  // J-type (JAL)
    input [20:0] imm21;  // imm[0]=0
    input [4:0] rd;
    input [6:0] opc;
    reg [31:0] t;
    begin
      t[31]    = imm21[20];
      t[19:12] = imm21[19:12];
      t[20]    = imm21[11];
      t[30:21] = imm21[10:1];
      t[6:0]   = opc;
      t[11:7]  = rd;
      enc_j    = t;
    end
  endfunction

  // ---- Test Stimulus ----
  initial begin
    $display("Starting control unit tests...");
    $dumpfile("control_tb.vcd");
    $dumpvars(0, control_tb);

    passed = 0;
    failed = 0;

    // ---------------- R-type ----------------
    reset_inputs();
    is_alu_reg = 1'b1;
    instr = 32'h00000033;  // opcode 0110011 shape
    expect_ctrl(0, 0, 0, 0, 0, 2'b10, `Imm_NONE, `WB_ALU, OP1_RS1,
                "R-type: decode by funct3/funct7 (op1=RS1)");

    // ------------- I-type: ADDI -------------
    reset_inputs();
    is_alu_imm = 1'b1;
    instr = enc_i(12'd5, 5'd2, 3'b000, 5'd1, `OP_ITYPE);
    expect_ctrl(0, 0, 1, 0, 0, 2'b00, `Imm_I, `WB_ALU, OP1_RS1,
                "ADDI: alu_op=00, ALUSrc=1, op1=RS1, WB_ALU");

    // ------------- I-type: ANDI -------------
    reset_inputs();
    is_alu_imm = 1'b1;
    instr = enc_i(12'd7, 5'd2, 3'b111, 5'd1, `OP_ITYPE);
    expect_ctrl(0, 0, 1, 0, 0, 2'b10, `Imm_I, `WB_ALU, OP1_RS1,
                "ANDI: decode path, op1=RS1, WB_ALU");

    // ------------- I-type: ORI --------------
    reset_inputs();
    is_alu_imm = 1'b1;
    instr = enc_i(12'd8, 5'd2, 3'b110, 5'd1, `OP_ITYPE);
    expect_ctrl(0, 0, 1, 0, 0, 2'b10, `Imm_I, `WB_ALU, OP1_RS1,
                "ORI: decode path, op1=RS1, WB_ALU");

    // ------------- I-type: XORI -------------
    reset_inputs();
    is_alu_imm = 1'b1;
    instr = enc_i(12'd9, 5'd2, 3'b100, 5'd1, `OP_ITYPE);
    expect_ctrl(0, 0, 1, 0, 0, 2'b10, `Imm_I, `WB_ALU, OP1_RS1,
                "XORI: decode path, op1=RS1, WB_ALU");

    // ------------- I-type: SLTI -------------
    reset_inputs();
    is_alu_imm = 1'b1;
    instr = enc_i(12'd1, 5'd2, 3'b010, 5'd1, `OP_ITYPE);
    expect_ctrl(0, 0, 1, 0, 0, 2'b10, `Imm_I, `WB_ALU, OP1_RS1,
                "SLTI: decode path, op1=RS1, WB_ALU");

    // ----------- I-type: SLTIU --------------
    reset_inputs();
    is_alu_imm = 1'b1;
    instr = enc_i(12'd1, 5'd2, 3'b011, 5'd1, `OP_ITYPE);
    expect_ctrl(0, 0, 1, 0, 0, 2'b10, `Imm_I, `WB_ALU, OP1_RS1,
                "SLTIU: decode path, op1=RS1, WB_ALU");

    // ------------- I-type: SLLI -------------
    reset_inputs();
    is_alu_imm = 1'b1;
    instr = enc_i({7'b0000000, 5'd3}, 5'd2, 3'b001, 5'd1, `OP_ITYPE);
    expect_ctrl(0, 0, 1, 0, 0, 2'b10, `Imm_I, `WB_ALU, OP1_RS1,
                "SLLI: decode path, op1=RS1, WB_ALU");

    // ------------- I-type: SRLI -------------
    reset_inputs();
    is_alu_imm = 1'b1;
    instr = enc_i({7'b0000000, 5'd3}, 5'd2, 3'b101, 5'd1, `OP_ITYPE);
    expect_ctrl(0, 0, 1, 0, 0, 2'b10, `Imm_I, `WB_ALU, OP1_RS1,
                "SRLI: decode path, op1=RS1, WB_ALU");

    // ------------- I-type: SRAI -------------
    reset_inputs();
    is_alu_imm = 1'b1;
    instr = enc_i({7'b0100000, 5'd3}, 5'd2, 3'b101, 5'd1, `OP_ITYPE);
    expect_ctrl(0, 0, 1, 0, 0, 2'b10, `Imm_I, `WB_ALU, OP1_RS1,
                "SRAI: decode path, op1=RS1, WB_ALU");

    // ----------------- LOAD -----------------
    reset_inputs();
    is_load = 1'b1;
    instr   = enc_i(12'd16, 5'd4, 3'b010, 5'd6, `OP_LOAD);
    expect_ctrl(1, 0, 1, 0, 0, 2'b00, `Imm_I, `WB_MEM, OP1_RS1,
                "LOAD (LW): mem_read=1, ALUSrc=1, op1=RS1, WB_MEM");

    // ---------------- STORE -----------------
    reset_inputs();
    is_store = 1'b1;
    instr = enc_s(12'd20, 5'd7, 5'd4, 3'b010, `OP_STORE);
    expect_ctrl(0, 1, 1, 0, 0, 2'b00, `Imm_S, `WB_ALU, OP1_RS1,
                "STORE (SW): mem_write=1, ALUSrc=1, op1=RS1, WB_ALU");

    // --------------- BRANCH -----------------
    reset_inputs();
    is_branch = 1'b1;
    instr = enc_b(13'd8, 5'd3, 5'd2, 3'b000, `OP_BRANCH);
    expect_ctrl(0, 0, 0, 1, 0, 2'b01, `Imm_B, `WB_ALU, OP1_RS1,
                "BRANCH (BEQ): alu_op=01, branch_sig=1, op1=RS1, WB_ALU");

    // ----------------- JAL ------------------
    reset_inputs();
    is_jal = 1'b1;
    instr  = enc_j(21'd16, 5'd1, `OP_JAL);
    expect_ctrl(0, 0, 1, 0, 1, 2'b00, `Imm_J, `WB_PC4, OP1_PC,
                "JAL: ALUSrc=1, jump=1, op1=PC, WB_PC4");

    // ---------------- JALR ------------------
    reset_inputs();
    is_jalr = 1'b1;
    instr   = enc_i(12'd4, 5'd2, 3'b000, 5'd1, `OP_JALR);
    expect_ctrl(0, 0, 1, 0, 1, 2'b00, `Imm_I, `WB_PC4, OP1_RS1,
                "JALR: ALUSrc=1, jump=1, op1=RS1, WB_PC4");

    // ----------------- LUI ------------------
    reset_inputs();
    is_lui = 1'b1;
    instr  = enc_u(20'h12345, 5'd10, `OP_LUI);
    expect_ctrl(0, 0, 1'b1, 0, 0, 2'b00, `Imm_U, `WB_ALU, OP1_ZERO,
                "LUI: ALUSrc=1, op1=ZERO, imm=U, WB_ALU");

    // ---------------- AUIPC -----------------
    reset_inputs();
    is_auipc = 1'b1;
    instr = enc_u(20'h23456, 5'd11, `OP_AUIPC);
    expect_ctrl(0, 0, 1, 0, 0, 2'b00, `Imm_U, `WB_ALU, OP1_PC,
                "AUIPC: ALUSrc=1, op1=PC, imm=U, WB_ALU");

    // ---- Summary ----
    $display("\nSummary:");
    $display("  Total: %0d   Passed: %0d   Failed: %0d", passed + failed, passed, failed);
    $finish;
  end

endmodule
