module alu_control_tb;

  reg [1:0] ALUOp;
  reg [2:0] funct3;
  reg funct7_5;
  wire [3:0] ALUCtrl;

  alu_control uut (
      .ALUOp(ALUOp),
      .funct3(funct3),
      .funct7_5(funct7_5),
      .ALUCtrl(ALUCtrl)
  );

  // ALU Control Signals
  localparam ALU_ADD = 4'b0000;
  localparam ALU_SUB = 4'b0001;
  localparam ALU_SLL = 4'b0010;
  localparam ALU_SLT = 4'b0011;
  localparam ALU_SLTU = 4'b0100;
  localparam ALU_XOR = 4'b0101;
  localparam ALU_SRL = 4'b0110;
  localparam ALU_SRA = 4'b0111;
  localparam ALU_OR = 4'b1000;
  localparam ALU_AND = 4'b1001;
  localparam ALU_LUI = 4'b1010;

  integer failed, passed;

  task check_output(input [3:0] expected, input [3:0] actual, input string test_name);
    if (actual !== expected) begin
      $display("%s failed: expected %b, got %b", test_name, expected, actual);
      failed = failed + 1;
    end else begin
      $display("%s passed: got %b", test_name, actual);
      passed = passed + 1;
    end
  endtask


  initial begin
    // dump waveform
    $dumpfile("dump.vcd");
    $dumpvars(0, alu_control_tb);

    passed = 0;
    failed = 0;


    // Test cases
    $display("\n--- ALU Control Testbench Start ---\n");

    // Test case 1: ALUOp = 00 (ADD)
    ALUOp = 2'b00;
    funct3 = 3'b101;
    funct7_5 = 1;
    #1;
    check_output(ALU_ADD, ALUCtrl, "Test Case 1");

    // Test case 2: ALUOp = 01 (SUB)
    ALUOp = 2'b01;
    funct3 = 3'b010;
    funct7_5 = 1;
    #1;
    check_output(ALU_SUB, ALUCtrl, "Test Case 2");

    // Test case 3: ALUOp = 10, funct3 = 000, funct7_5 = 0 (ADD)
    ALUOp = 2'b10;
    funct3 = 3'b000;
    funct7_5 = 0;
    #1;
    check_output(ALU_ADD, ALUCtrl, "Test Case 3");

    // Test case 4: ALUOp = 10, funct3 = 000, funct7_5 = 1 (SUB)
    ALUOp = 2'b10;
    funct3 = 3'b000;
    funct7_5 = 1;
    #1;
    check_output(ALU_SUB, ALUCtrl, "Test Case 4");

    // Test case 5: ALUOp = 10, funct3 = 001, funct7_5 = 0 (SLL)
    ALUOp = 2'b10;
    funct3 = 3'b001;
    funct7_5 = 0;
    #1;
    check_output(ALU_SLL, ALUCtrl, "Test Case 5");

    // Test case 6: ALUOp = 10, funct3 = 010, funct7_5 = 0 (SLT)
    ALUOp = 2'b10;
    funct3 = 3'b010;
    funct7_5 = 0;
    #1;
    check_output(ALU_SLT, ALUCtrl, "Test Case 6");

    // Test case 7: ALUOp = 10, funct3 = 011, funct7_5 = 0 (SLTU)
    ALUOp = 2'b10;
    funct3 = 3'b011;
    funct7_5 = 0;
    #1;
    check_output(ALU_SLTU, ALUCtrl, "Test Case 7");

    // Test case 8: ALUOp = 10, funct3 = 100, funct7_5 = 0 (XOR)
    ALUOp = 2'b10;
    funct3 = 3'b100;
    funct7_5 = 0;
    #1;
    check_output(ALU_XOR, ALUCtrl, "Test Case 8");

    // Test case 9: ALUOp = 10, funct3 = 101, funct7_5 = 0 (SRL)
    ALUOp = 2'b10;
    funct3 = 3'b101;
    funct7_5 = 0;
    #1;
    check_output(ALU_SRL, ALUCtrl, "Test Case 9");

    // Test case 10: ALUOp = 10, funct3 = 101, funct7_5 = 1 (SRA)
    ALUOp = 2'b10;
    funct3 = 3'b101;
    funct7_5 = 1;
    #1;
    check_output(ALU_SRA, ALUCtrl, "Test Case 10");

    // Test case 11: ALUOp = 10, funct3 = 110, funct7_5 = 0 (OR)
    ALUOp = 2'b10;
    funct3 = 3'b110;
    funct7_5 = 0;
    #1;
    check_output(ALU_OR, ALUCtrl, "Test Case 11");

    // Test case 12: ALUOp = 10, funct3 = 111, funct7_5 = 0 (AND)
    ALUOp = 2'b10;
    funct3 = 3'b111;
    funct7_5 = 0;
    #1;
    check_output(ALU_AND, ALUCtrl, "Test Case 12");

    // Test case 13: ALUOp = 11 (LUI)
    ALUOp = 2'b11;
    funct3 = 3'b000;
    funct7_5 = 0;
    #1;
    check_output(ALU_LUI, ALUCtrl, "Test Case 13");

    $display("\n--- ALU Control Testbench End ---\n");
    $display("Total Tests Passed: %d", passed);
    $display("Total Tests Failed: %d", failed);

  end

endmodule
