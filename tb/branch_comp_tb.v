`timescale 1ps / 1ps
module branch_comp_tb;

  // DUT I/O
  reg signed [31:0] op1;
  reg signed [31:0] op2;
  reg        [ 2:0] funct3;
  wire              branch;

  branch_comp uut (
      .op1         (op1),
      .op2         (op2),
      .funct3      (funct3),
      .branch_taken(branch)
  );

  integer failed, passed;

  // Verilog-2001: no 'string' type; use a packed byte vector for messages.
  // This supports up to 64 characters.
  task check_output;
    input expected;
    input actual;
    input [8*64-1:0] test_name;
    begin
      if (actual !== expected) begin
        $display("%0s failed: expected %b, got %b", test_name, expected, actual);
        failed = failed + 1;
      end else begin
        $display("%0s passed: got %b", test_name, actual);
        passed = passed + 1;
      end
    end
  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, branch_comp_tb);

    passed = 0;
    failed = 0;

    $display("\n--- Branch Comparator Testbench Start ---\n");

    // BEQ
    op1    = 32'hA5A5A5A5;
    op2    = 32'hA5A5A5A5;
    funct3 = 3'b000;
    #1;
    check_output(1'b1, branch, "BEQ");

    op1    = 32'hA5A5A5A5;
    op2    = 32'hB5B5B5B5;
    funct3 = 3'b000;
    #1;
    check_output(1'b0, branch, "BEQ (Negative)");

    // BNE
    op2    = 32'hB6B6B6B6;
    funct3 = 3'b001;
    #1;
    check_output(1'b1, branch, "BNE");

    op1    = 32'hB6B6B6B6;
    op2    = 32'hB6B6B6B6;
    funct3 = 3'b001;
    #1;
    check_output(1'b0, branch, "BNE (Negative)");

    // BLT (signed)
    op1    = -32'd10;
    op2    = -32'd5;
    funct3 = 3'b100;
    #1;
    check_output(1'b1, branch, "BLT");

    op1    = 32'd2;
    op2    = -32'd5;
    funct3 = 3'b100;
    #1;
    check_output(1'b0, branch, "BLT (Negative)");

    // BGE (signed)
    op1    = -32'd5;
    op2    = -32'd10;
    funct3 = 3'b101;
    #1;
    check_output(1'b1, branch, "BGE");

    op1    = -32'd20;
    op2    = -32'd10;
    funct3 = 3'b101;
    #1;
    check_output(1'b0, branch, "BGE (Negative)");

    // BLTU (unsigned)
    op1    = 32'h00000001;
    op2    = 32'hFFFFFFFF;
    funct3 = 3'b110;
    #1;
    check_output(1'b1, branch, "BLTU");

    op1    = 32'hFFFFFFFF;
    op2    = 32'h00000001;
    funct3 = 3'b110;
    #1;
    check_output(1'b0, branch, "BLTU (Negative)");

    // BGEU (unsigned)
    op2    = 32'hFFFFFFFF;
    funct3 = 3'b111;
    #1;
    check_output(1'b1, branch, "BGEU");

    op2    = 32'hFFFFFFFF;
    op1    = 32'h00000001;
    funct3 = 3'b111;
    #1;
    check_output(1'b0, branch, "BGEU (Negative)");

    // Default/unsupported funct3
    funct3 = 3'b010;
    #1;
    check_output(1'b0, branch, "No Branch (Default)");

    $display("\n--- Branch Comparator Testbench End ---\n");
    $display("Total Tests: %0d, Passed: %0d, Failed: %0d", passed + failed, passed, failed);
    $finish;
  end

endmodule
