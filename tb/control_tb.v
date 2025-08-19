`timescale 1ns / 1ps
`include "defines.vh"

module control_tb;

  // Inputs
  reg [31:0] instr;
  reg ALUreg, ALUimm, Branch, JAL, JALR, LUI, AUIPC, Load, Store, SYSTEM;

  // Outputs
  wire MemRead, MemWrite, MemtoReg, ALUSrc, BranchSig, Jump;
  wire [1:0] ALUOp;
  wire [2:0] ImmSrc;

  // DUT
  control uut (
      .instr(instr),
      .ALUreg(ALUreg),
      .ALUimm(ALUimm),
      .Branch(Branch),
      .JAL(JAL),
      .JALR(JALR),
      .LUI(LUI),
      .AUIPC(AUIPC),
      .Load(Load),
      .Store(Store),
      .SYSTEM(SYSTEM),
      .MemRead(MemRead),
      .MemWrite(MemWrite),
      .MemtoReg(MemtoReg),
      .ALUSrc(ALUSrc),
      .BranchSig(BranchSig),
      .Jump(Jump),
      .ALUOp(ALUOp),
      .ImmSrc(ImmSrc)
  );

  integer failed, passed;

  task reset_inputs;
    begin
      {ALUreg, ALUimm, Branch, JAL, JALR, LUI, AUIPC, Load, Store, SYSTEM} = 10'b0;
      instr = 32'b0;
    end
  endtask

  task assert_control(input exp_MemRead, exp_MemWrite, exp_MemtoReg, input exp_ALUSrc,
                      exp_BranchSig, exp_Jump, input [1:0] exp_ALUOp, input [2:0] exp_ImmSrc,
                      input [127:0] label);
    #1;
    if (MemRead   !== exp_MemRead   ||
        MemWrite  !== exp_MemWrite  ||
        MemtoReg  !== exp_MemtoReg  ||
        ALUSrc    !== exp_ALUSrc    ||
        BranchSig !== exp_BranchSig ||
        Jump      !== exp_Jump      ||
        ALUOp     !== exp_ALUOp     ||
        ImmSrc    !== exp_ImmSrc) begin
      $display("FAIL [%s] at time %0t", label, $time);
      $display(
          "   Got     : MemRead=%b, MemWrite=%b, MemtoReg=%b, ALUSrc=%b, Branch=%b, Jump=%b, ALUOp=%02b, ImmSrc=%03b",
          MemRead, MemWrite, MemtoReg, ALUSrc, BranchSig, Jump, ALUOp, ImmSrc);
      $display(
          "   Expected: MemRead=%b, MemWrite=%b, MemtoReg=%b, ALUSrc=%b, Branch=%b, Jump=%b, ALUOp=%02b, ImmSrc=%03b",
          exp_MemRead, exp_MemWrite, exp_MemtoReg, exp_ALUSrc, exp_BranchSig, exp_Jump, exp_ALUOp,
          exp_ImmSrc);
      failed = failed + 1;
    end else begin
      $display("PASS [%s]", label);
      passed = passed + 1;
    end
  endtask

  initial begin
    $display("Starting control unit tests...\n");
    $dumpfile("dump.vcd");
    $dumpvars(0, control_tb);

    passed = 0;
    failed = 0;

    // R-type
    reset_inputs();
    ALUreg = 1;
    #1 assert_control(0, 0, 0, 0, 0, 0, 2'b10, 3'b000, "R-type");

    // I-type (ALU imm)
    reset_inputs();
    ALUimm = 1;
    #1 assert_control(0, 0, 0, 1, 0, 0, 2'b10, `Imm_I, "I-type");

    // Load
    reset_inputs();
    Load = 1;
    #1 assert_control(1, 0, 1, 1, 0, 0, 2'b00, `Imm_I, "Load");

    // Store
    reset_inputs();
    Store = 1;
    #1 assert_control(0, 1, 0, 1, 0, 0, 2'b00, `Imm_S, "Store");

    // Branch
    reset_inputs();
    Branch = 1;
    #1 assert_control(0, 0, 0, 0, 1, 0, 2'b01, `Imm_B, "Branch");

    // JAL
    reset_inputs();
    JAL = 1;
    #1 assert_control(0, 0, 0, 1, 0, 1, 2'b00, `Imm_J, "JAL");

    // JALR (only if funct3 = 000)
    reset_inputs();
    JALR = 1;
    instr[14:12] = 3'b000;
    #1 assert_control(0, 0, 0, 1, 0, 1, 2'b00, `Imm_I, "JALR funct3=000");

    // LUI
    reset_inputs();
    LUI = 1;
    #1 assert_control(0, 0, 0, 1, 0, 0, 2'b11, `Imm_U, "LUI");

    // AUIPC
    reset_inputs();
    AUIPC = 1;
    #1 assert_control(0, 0, 0, 1, 0, 0, 2'b00, `Imm_U, "AUIPC");

    $display("\nSummary of control unit tests:");
    $display("Total tests: %d", passed + failed);
    $display("Passed: %d", passed);
    $display("Failed: %d", failed);
    $finish;
  end

endmodule
