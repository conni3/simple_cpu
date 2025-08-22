`timescale 1ns / 1ps

module decoder_tb;

  // Inputs
  reg [31:0] instr;

  // Outputs
  wire ALUreg, regWrite, JAL, JALR, Branch, LUI, AUIPC, ALUimm, Load, Store;
  wire SYSTEM;  // used by DUT connection below

  // Instantiate the Unit Under Test (UUT)
  decoder dut (
      .instr     (instr),
      .is_alu_reg(ALUreg),
      .reg_write (regWrite),
      .is_jal    (JAL),
      .is_jalr   (JALR),
      .is_branch (Branch),
      .is_lui    (LUI),
      .is_auipc  (AUIPC),
      .is_alu_imm(ALUimm),
      .is_load   (Load),
      .is_store  (Store),
      .is_system (SYSTEM)
  );

  integer failed, passed;

  // Verilog-2001: replace 'string' with a byte vector and print via %0s
  task check_output;
    input [8*64-1:0] test_name;  // up to 64 chars
    input [31:0] instr_val;
    input exp_ALUreg, exp_ALUimm, exp_Branch, exp_JAL, exp_JALR;
    input exp_LUI, exp_AUIPC, exp_Load, exp_Store, exp_regWrite;
    begin
      instr = instr_val;
      #1;

      $display("Instr = %b, Test = %0s", instr, test_name);

      if (ALUreg !== exp_ALUreg)
        $display("ASSERTION FAILED: ALUreg   expected %b, got %b", exp_ALUreg, ALUreg);
      if (ALUimm !== exp_ALUimm)
        $display("ASSERTION FAILED: ALUimm   expected %b, got %b", exp_ALUimm, ALUimm);
      if (Branch !== exp_Branch)
        $display("ASSERTION FAILED: Branch   expected %b, got %b", exp_Branch, Branch);
      if (JAL !== exp_JAL) $display("ASSERTION FAILED: JAL      expected %b, got %b", exp_JAL, JAL);
      if (JALR !== exp_JALR)
        $display("ASSERTION FAILED: JALR     expected %b, got %b", exp_JALR, JALR);
      if (LUI !== exp_LUI) $display("ASSERTION FAILED: LUI      expected %b, got %b", exp_LUI, LUI);
      if (AUIPC !== exp_AUIPC)
        $display("ASSERTION FAILED: AUIPC    expected %b, got %b", exp_AUIPC, AUIPC);
      if (Load !== exp_Load)
        $display("ASSERTION FAILED: Load     expected %b, got %b", exp_Load, Load);
      if (Store !== exp_Store)
        $display("ASSERTION FAILED: Store    expected %b, got %b", exp_Store, Store);
      if (regWrite !== exp_regWrite)
        $display("ASSERTION FAILED: regWrite expected %b, got %b", exp_regWrite, regWrite);

      if (ALUreg   === exp_ALUreg   &&
          ALUimm   === exp_ALUimm   &&
          Branch   === exp_Branch   &&
          JAL      === exp_JAL      &&
          JALR     === exp_JALR     &&
          LUI      === exp_LUI      &&
          AUIPC    === exp_AUIPC    &&
          Load     === exp_Load     &&
          Store    === exp_Store    &&
          regWrite === exp_regWrite) begin
        passed = passed + 1;
        $display("Test passed: %0s", test_name);
      end else begin
        failed = failed + 1;
        $display("Test failed: %0s", test_name);
      end
    end
  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, decoder_tb);
    $display("Starting Decoder Testbench with Assertions\n");

    passed = 0;
    failed = 0;

    // R-type: add x3, x1, x2 (0110011)
    check_output("R-type: add x3, x1, x2", 32'b0000000_00010_00001_000_00011_0110011, 1, 0, 0, 0, 0,
                 0, 0, 0, 0, 1);

    // I-type: addi x3, x1, 5 (0010011)
    check_output("I-type: addi x3, x1, 5", 32'b000000000101_00001_000_00011_0010011, 0, 1, 0, 0, 0,
                 0, 0, 0, 0, 1);

    // Load: lw x3, 4(x1) (0000011)
    check_output("Load: lw x3, 4(x1)", 32'b000000000100_00001_010_00011_0000011, 0, 0, 0, 0, 0, 0,
                 0, 1, 0, 1);

    // Store: sw x3, 4(x1) (0100011)
    check_output("Store: sw x3, 4(x1)", 32'b0000000_00011_00001_010_00100_0100011, 0, 0, 0, 0, 0, 0,
                 0, 0, 1, 0);

    // Branch: beq x1, x3, offset (1100011)
    check_output("Branch: beq x1, x3, offset", 32'b0000000_00011_00001_000_00010_1100011, 0, 0, 1,
                 0, 0, 0, 0, 0, 0, 0);

    // JALR: jalr x3, 4(x1) (1100111)
    check_output("JALR: jalr x3, 4(x1)", 32'b000000000100_00001_000_00011_1100111, 0, 0, 0, 0, 1, 0,
                 0, 0, 0, 1);

    // JAL: jal x3, offset (1101111)
    check_output("JAL: jal x3, offset", 32'b00000000000000000000_00011_1101111, 0, 0, 0, 1, 0, 0,
                 0, 0, 0, 1);

    // LUI: lui x3, 1 (0110111)
    check_output("LUI: lui x3, 1", 32'b00000000000000000001_00011_0110111, 0, 0, 0, 0, 0, 1, 0, 0,
                 0, 1);

    // AUIPC: auipc x3, 1 (0010111)
    check_output("AUIPC: auipc x3, 1", 32'b00000000000000000001_00011_0010111, 0, 0, 0, 0, 0, 0, 1,
                 0, 0, 1);

    $display("\nDecoder Testbench Summary:");
    $display("Total Tests: %0d", passed + failed);
    $display("Passed: %0d", passed);
    $display("Failed: %0d", failed);

    $finish;
  end

endmodule
