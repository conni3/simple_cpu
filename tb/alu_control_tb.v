`timescale 1ns / 1ps

module alu_control_tb;

  reg  [1:0] ALUOp;
  reg  [2:0] funct3;
  reg        funct7_5;
  wire [3:0] ALUCtrl;

  alu_control uut (
      .alu_op  (ALUOp),
      .funct3  (funct3),
      .funct7_5(funct7_5),
      .alu_ctrl(ALUCtrl)
  );
  localparam [3:0] ALU_ADD = 4'b0000;
  localparam [3:0] ALU_SUB = 4'b0001;
  localparam [3:0] ALU_SLL = 4'b0010;
  localparam [3:0] ALU_SLT = 4'b0011;
  localparam [3:0] ALU_SLTU = 4'b0100;
  localparam [3:0] ALU_XOR = 4'b0101;
  localparam [3:0] ALU_SRL = 4'b0110;
  localparam [3:0] ALU_SRA = 4'b0111;
  localparam [3:0] ALU_OR = 4'b1000;
  localparam [3:0] ALU_AND = 4'b1001;

  integer failed, passed;

  task check_output;
    input [3:0] expected;
    input [3:0] actual;
    input [8*32-1:0] test_name;
    begin
      if (actual !== expected) begin
        $display("%s failed: expected %b, got %b", test_name, expected, actual);
        failed = failed + 1;
      end else begin
        $display("%s passed: got %b", test_name, actual);
        passed = passed + 1;
      end
    end
  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, alu_control_tb);

    passed = 0;
    failed = 0;

    $display("\n--- ALU Control Testbench Start ---\n");

    // Test case 1: ALUOp = 00 (ADD) - generic add path
    ALUOp = 2'b00;
    funct3 = 3'b101;
    funct7_5 = 1'b1;
    #1;
    check_output(ALU_ADD, ALUCtrl, "Test 1: ALUOp00 -> ADD");

    // Test case 2: ALUOp = 01 (SUB) - generic branch/sub path
    ALUOp = 2'b01;
    funct3 = 3'b010;
    funct7_5 = 1'b1;
    #1;
    check_output(ALU_SUB, ALUCtrl, "Test 2: ALUOp01 -> SUB");

    // Test case 3: R/imm map: ADD (funct3=000, f7=0)
    ALUOp = 2'b10;
    funct3 = 3'b000;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_ADD, ALUCtrl, "Test 3: Op10 f3=000 f7=0 -> ADD");

    // Test case 4: R map: SUB (funct3=000, f7=1)
    ALUOp = 2'b10;
    funct3 = 3'b000;
    funct7_5 = 1'b1;
    #1;
    check_output(ALU_SUB, ALUCtrl, "Test 4: Op10 f3=000 f7=1 -> SUB");

    // Test case 5: SLL
    ALUOp = 2'b10;
    funct3 = 3'b001;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_SLL, ALUCtrl, "Test 5: SLL");

    // Test case 6: SLT
    ALUOp = 2'b10;
    funct3 = 3'b010;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_SLT, ALUCtrl, "Test 6: SLT");

    // Test case 7: SLTU
    ALUOp = 2'b10;
    funct3 = 3'b011;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_SLTU, ALUCtrl, "Test 7: SLTU");

    // Test case 8: XOR
    ALUOp = 2'b10;
    funct3 = 3'b100;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_XOR, ALUCtrl, "Test 8: XOR");

    // Test case 9: SRL
    ALUOp = 2'b10;
    funct3 = 3'b101;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_SRL, ALUCtrl, "Test 9: SRL");

    // Test case 10: SRA
    ALUOp = 2'b10;
    funct3 = 3'b101;
    funct7_5 = 1'b1;
    #1;
    check_output(ALU_SRA, ALUCtrl, "Test 10: SRA");

    // Test case 11: OR
    ALUOp = 2'b10;
    funct3 = 3'b110;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_OR, ALUCtrl, "Test 11: OR");

    // Test case 12: AND
    ALUOp = 2'b10;
    funct3 = 3'b111;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_AND, ALUCtrl, "Test 12: AND");

    // Test case 13: LUI (U-type, if your control maps it here)
    ALUOp = 2'b11;
    funct3 = 3'b000;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_ADD, ALUCtrl, "Test 13: LUI");

    // Test 14: ADDI -> force ADD via ALUOp=00 (funct3 ignored here)
    ALUOp = 2'b00;
    funct3 = 3'b000;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_ADD, ALUCtrl, "Test 14: ADDI (ALUOp=00)");

    // Test 15: ANDI -> ALUOp=10, f3=111
    ALUOp = 2'b10;
    funct3 = 3'b111;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_AND, ALUCtrl, "Test 15: ANDI");

    // Test 16: ORI -> ALUOp=10, f3=110
    ALUOp = 2'b10;
    funct3 = 3'b110;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_OR, ALUCtrl, "Test 16: ORI");

    // Test 17: XORI -> ALUOp=10, f3=100
    ALUOp = 2'b10;
    funct3 = 3'b100;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_XOR, ALUCtrl, "Test 17: XORI");

    // Test 18: SLTI -> ALUOp=10, f3=010
    ALUOp = 2'b10;
    funct3 = 3'b010;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_SLT, ALUCtrl, "Test 18: SLTI");

    // Test 19: SLTIU -> ALUOp=10, f3=011
    ALUOp = 2'b10;
    funct3 = 3'b011;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_SLTU, ALUCtrl, "Test 19: SLTIU");

    // Test 20: SLLI -> ALUOp=10, f3=001, instr[30]=0
    ALUOp = 2'b10;
    funct3 = 3'b001;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_SLL, ALUCtrl, "Test 20: SLLI");

    // Test 21: SRLI -> ALUOp=10, f3=101, instr[30]=0
    ALUOp = 2'b10;
    funct3 = 3'b101;
    funct7_5 = 1'b0;
    #1;
    check_output(ALU_SRL, ALUCtrl, "Test 21: SRLI");

    // Test 22: SRAI -> ALUOp=10, f3=101, instr[30]=1
    ALUOp = 2'b10;
    funct3 = 3'b101;
    funct7_5 = 1'b1;
    #1;
    check_output(ALU_SRA, ALUCtrl, "Test 22: SRAI");

    $display("\n--- ALU Control Testbench End ---\n");
    $display("Total Tests Passed: %0d", passed);
    $display("Total Tests Failed: %0d", failed);

    $finish;
  end

endmodule
