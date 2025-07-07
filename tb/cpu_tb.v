`timescale 1ns / 1ps

module cpu_tb;
  reg clk;
  reg reset;
  // instantiate your cpu
  cpu uut (
      .clk  (clk),
      .reset(reset)
  );

  // generate a 10 ns clock
  initial clk = 0;
  always #5 clk = ~clk;

  // apply reset for two cycles
  initial begin
    reset = 1;
    #12;  // hold reset through >1 cycle
    reset = 0;

    $display("---- Running CPU Testbench ----");

    $dumpfile("dump.vcd");
    $dumpvars(0, cpu_tb);

    $display("   time   |    PC    |  INSTR");
    $display("-------------------------------");
    #15;  // wait until reset de-asserted
    forever
    #10 begin
      $display("%8t | %08h | %08h", $time, uut.current_pc, uut.current_instr);
    end
  end

  // finish after 100 cycles
  initial #1000 $finish;
endmodule
