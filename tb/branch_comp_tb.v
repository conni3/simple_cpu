module branch_comp_tb;
  reg signed [31:0] op1;
  reg signed [31:0] op2;
  reg  [ 2:0] funct3;
  wire        branch;

  branch_comp uut (
      .op1(op1),
      .op2(op2),
      .funct3(funct3),
      .branch(branch)
  );
  integer failed, passed;

  task check_output(input expected, input actual, input string test_name);
    if (actual !== expected) begin
      $display("%s failed: expected %b, got %b", test_name, expected, actual);
      failed = failed + 1;
    end else begin
      $display("%s passed: got %b", test_name, actual);
      passed = passed + 1;
    end
  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, branch_comp_tb);

    passed = 0;
    failed = 0;

    $display("\n--- Branch Comparator Testbench Start ---\n");

    op1 = 32'hA5A5A5A5;
    op2 = 32'hA5A5A5A5;
    funct3 = 3'b000;
    #1;
    check_output(1'b1, branch, "BEQ");

    op1 = 32'hA5A5A5A5;
    op2 = 32'hB5B5B5B5;
    funct3 = 3'b000;
    #1;
    check_output(1'b0, branch, "BEQ (Negative)");

    op2 = 32'hB6B6B6B6;
    funct3 = 3'b001;
    #1;
    check_output(1'b1, branch, "BNE");

    op1 = 32'hB6B6B6B6;
    op2 = 32'hB6B6B6B6;
    funct3 = 3'b001;
    #1;
    check_output(1'b0, branch, "BNE (Negative)");


    op1 = -32'd10;
    op2 = -32'd5;
    funct3 = 3'b100;
    #1;
    check_output(1'b1, branch, "BLT");

    op1 = 32'd2;
    op2 = -32'd5;
    funct3 = 3'b100;
    #1;
    check_output(1'b0, branch, "BLT (Negative)");


    op1 = -32'd5;
    op2 = -32'd10;
    funct3 = 3'b101;
    #1;
    check_output(1'b1, branch, "BGE");

    op1 = -32'd20;
    op2 = -32'd10;
    funct3 = 3'b101;
    #1;
    check_output(1'b0, branch, "BGE (Negative)");

    op1 = 32'h00000001;
    op2 = 32'hFFFFFFFF;
    funct3 = 3'b110;
    #1;
    check_output(1'b1, branch, "BLTU");

    op1 = 32'hFFFFFFFF;
    op2 = 32'h00000001;
    funct3 = 3'b110;
    #1;
    check_output(1'b0, branch, "BLTU (Negative)");


    op2 = 32'hFFFFFFFF;
    funct3 = 3'b111;
    #1;
    check_output(1'b1, branch, "BGEU");

    op2 = 32'hFFFFFFFF;
    op1 = 32'h00000001;
    funct3 = 3'b111;
    #1;
    check_output(1'b0, branch, "BGEU (Negative)");

    funct3 = 3'b010;
    #1;
    check_output(1'b0, branch, "No Branch (Default)");

    $display("\n--- Branch Comparator Testbench End ---\n");

    $display("Total Tests: %d, Passed: %d, Failed: %d", passed + failed, passed, failed);

  end



endmodule
