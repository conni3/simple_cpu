`timescale 1ns / 1ps
module cpu_tb;

  reg clk = 0;
  reg reset = 1;
  cpu uut (
      .clk  (clk),
      .reset(reset)
  );


  always #5 clk = ~clk;


  initial begin
    #16 reset = 0;
  end


  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, cpu_tb);
    #500 $finish;
  end


  initial begin
    $display(" time |    PC    |  INSTR");
    $monitor("%5t | %h | %h", $time, cpu.current_pc, cpu.current_instr);
  end


endmodule
