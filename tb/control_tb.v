`include "include/defines.vh"

module control_tb;

  reg  [6:0]  opcode;
  reg  [2:0]  funct3;
  wire        RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, Branch, Jump;
  wire [1:0]  ALUOp;
  wire [2:0]  ImmSrc;

  integer passed, failed;

  control uut (
      .opcode   (opcode),
      .funct3   (funct3),
      .RegWrite (RegWrite),
      .MemRead  (MemRead),
      .MemWrite (MemWrite),
      .MemtoReg (MemtoReg),
      .ALUSrc   (ALUSrc),
      .Branch   (Branch),
      .Jump     (Jump),
      .ALUOp    (ALUOp),
      .ImmSrc   (ImmSrc)
  );

  // now takes 10 inputs (no exp_PCsrc)
  task check_output(
    input        exp_RegWrite,
    input        exp_MemRead,
    input        exp_MemWrite,
    input        exp_MemtoReg,
    input        exp_ALUSrc,
    input        exp_Branch,
    input        exp_Jump,
    input [1:0]  exp_ALUOp,
    input [2:0]  exp_ImmSrc,
    input string message
  );
    if (RegWrite  !== exp_RegWrite ||
        MemRead   !== exp_MemRead  ||
        MemWrite  !== exp_MemWrite ||
        MemtoReg  !== exp_MemtoReg ||
        ALUSrc    !== exp_ALUSrc   ||
        Branch    !== exp_Branch   ||
        Jump      !== exp_Jump     ||
        ALUOp     !== exp_ALUOp    ||
        ImmSrc    !== exp_ImmSrc) begin
      $display("Test failed: %s", message);
      failed = failed + 1;
    end else begin
      $display("Test passed: %s", message);
      passed = passed + 1;
    end
  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, control_tb);

    passed = 0;
    failed = 0;

    opcode = `OP_RTYPE;
    #10;
    check_output(
      1'b1, 1'b0, 1'b0, 1'b0,  // RegWrite, MemRead, MemWrite, MemtoReg
      1'b0,                    // ALUSrc
      1'b0,                    // Branch
      1'b0,                    // Jump
      2'b10,                   // ALUOp
      3'b000,                  // ImmSrc
      "R-type ADD"
    );

    opcode = `OP_ITYPE;
    #10;
    check_output(1'b1,1'b0,1'b0,1'b0, 1'b1, 1'b0, 1'b0, 2'b10, `Imm_I, "I-type ADDI");

    opcode = `OP_LOAD;
    #10;
    check_output(1'b1,1'b1,1'b0,1'b1, 1'b1, 1'b0, 1'b0, 2'b00, `Imm_I, "Load LW");

    opcode = `OP_STORE;
    #10;
    check_output(1'b0,1'b0,1'b1,1'b0, 1'b1, 1'b0, 1'b0, 2'b00, `Imm_S, "Store SW");

    opcode = `OP_BRANCH;
    #10;
    check_output(1'b0,1'b0,1'b0,1'b0, 1'b0, 1'b1, 1'b0, 2'b01, `Imm_B, "Branch BEQ");

    opcode = `OP_JAL;
    #10;
    check_output(1'b1,1'b0,1'b0,1'b0, 1'b1, 1'b0, 1'b1, 2'b00, `Imm_J, "Jump JAL");

    opcode = `OP_JALR;
    funct3 = 3'b000;
    #10;
    check_output(1'b1,1'b0,1'b0,1'b0, 1'b1, 1'b0, 1'b1, 2'b00, `Imm_I, "Jump JALR");

    opcode = `OP_LUI;
    #10;
    check_output(1'b1,1'b0,1'b0,1'b0, 1'b1, 1'b0, 1'b0, 2'b11, `Imm_U, "Load Upper LUI");

    opcode = `OP_AUIPC;
    #10;
    check_output(1'b1,1'b0,1'b0,1'b0, 1'b1, 1'b0, 1'b0, 2'b00, `Imm_U, "Add Upper Immediate AUIPC");

    if (failed == 0) begin
      $display("All tests passed!");
    end else begin
      $display("%0d tests passed, %0d tests failed.", passed, failed);
    end
    $finish;
  end

endmodule
