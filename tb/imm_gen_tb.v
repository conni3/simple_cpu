`timescale 1ns / 1ps

module imm_gen_tb;

  reg  [31:0] instr;
  reg  [ 2:0] imm_sel;

  wire [31:0] imm_out;


  reg  [31:0] expected;
  integer passed, failed;

  imm_gen uut (
      .instr  (instr),
      .imm_sel(imm_sel),
      .imm_out(imm_out)
  );


  task check;
    input [31:0] test_instr;
    input [2:0] sel;
    input [31:0] exp;
    begin
      instr   = test_instr;
      imm_sel = sel;
      #2;
      expected = exp;

      if (imm_out === expected) begin
        passed = passed + 1;
        $display("PASS: sel=%b instr=0x%08h -> imm_out=0x%08h", sel, instr, imm_out);
      end else begin
        failed = failed + 1;
        $error("FAIL: sel=%b instr=0x%08h -> expected=0x%08h, got=0x%08h", sel, instr, expected,
               imm_out);
      end
    end
  endtask

  initial begin

    $dumpfile("dump.vcd");
    $dumpvars(0, imm_gen_tb);


    passed = 0;
    failed = 0;

    $display("\n--- IMMGEN Enhanced Testbench Start ---\n");

    // I-Type Immediates
    check(32'h7FF00000, 3'b000, 32'h000007FF);  // +2047
    check(32'h80000000, 3'b000, 32'hFFFFF800);  // -2048
    check(32'h12300000, 3'b000, 32'h00000123);  // +0x123 (bits[31:20]=0x123)

    // S-Type Store Offsets
    check(32'h0000A223, 3'b001, 32'h00000004);  // +4  (imm[11:5]=0, imm[4:0]=00100)
    check(32'hFE002423, 3'b001, 32'hFFFFFFE8);  // -24 (imm[11:5]=1111111, imm[4:0]=00111)

    // B-Type Branch Offsets
    check(32'h04000063, 3'b010, 32'h00000040);  // +16 (imm=0x010 <<1)
    check(32'hFE0000E3, 3'b010, -32);  // -32 (imm=0xFF0 <<1 signed)

    // U-Type Upper Immediates
    check(32'h12345000, 3'b011, 32'h12345000);  // imm[31:12]=0x12345
    check(32'hFFFFF000, 3'b011, 32'hFFFFF000);  // imm[31:12]=0xFFFFF

    // J-Type Jump Offsets
    check(32'h004000EF, 3'b100, 32'd4);  // +1024 (j10:1=0b1000000000)
    check(32'h801FF06F, 3'b100, -2048);  // -2048 (imm21 two's complement)

    $display("\n--- IMMGEN Test Results ---");
    $display("Passed: %0d, Failed: %0d", passed, failed);
    if (failed > 0) begin
      $display("Some tests failed.");
      $fatal;
    end else begin
      $display("All tests passed!\n");
    end
    $finish;
  end
endmodule
