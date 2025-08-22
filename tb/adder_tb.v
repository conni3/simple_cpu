`timescale 1ns / 1ps

module adder_tb;

  localparam WIDTH = 32;
  reg  [WIDTH-1:0] a;
  reg  [WIDTH-1:0] b;
  wire [WIDTH-1:0] result;
  integer passed, failed;

  adder #(
      .WIDTH(WIDTH)
  ) uut (
      .a(a),
      .b(b),
      .result(result)
  );


  task check;
    input [WIDTH-1:0] test_a;
    input [WIDTH-1:0] test_b;
    input [WIDTH-1:0] expected;
    begin
      a = test_a;
      b = test_b;
      #2;  // allow combinational logic to settle

      if (result === expected) begin
        passed = passed + 1;
        $display("PASS: a=0x%08h b=0x%08h -> result=0x%08h", a, b, result);
      end else begin
        $display("FAIL: a=0x%08h b=0x%08h -> expected=0x%08h, got=0x%08h", a, b, expected, result);
        failed = failed + 1;
      end
    end

  endtask


  initial begin
    // dump waveform
    $dumpfile("dump.vcd");
    $dumpvars(0, adder_tb);

    // Initialize counters
    passed = 0;
    failed = 0;

    $display("\n--- ADDER Testbench Start ---\n");

    // Test cases
    check(32'h00000001, 32'h00000001, 32'h00000002);  // 1 + 1 = 2
    check(32'hFFFFFFFF, 32'h00000001, 32'h00000000);  // -1 + 1 = 0
    check(32'h7FFFFFFF, 32'h00000001, 32'h80000000);  // max positive + 1 = min negative
    check(32'h80000000, 32'hFFFFFFFF, 32'h7FFFFFFF);  // min negative + -1 = max positive

    $display("\n--- ADDER Testbench End ---\n");
    $display("Total Passed: %d, Total Failed: %d", passed, failed);

    $finish;

  end


endmodule

