
`timescale 1ns / 1ps

module pc_tb;
  // Inputs to DUT
  reg         clk;
  reg         reset;
  reg  [31:0] next_pc;
  // Output from DUT
  wire [31:0] current_pc;

  // Instantiate the PC module (Device Under Test)
  pc uut (
      .clk       (clk),
      .reset     (reset),
      .next_pc   (next_pc),
      .current_pc(current_pc)
  );

  // 1) Clock generator: 10 ns period (100 MHz)
  initial clk = 0;
  always #5 clk = ~clk;

  // 2) Stimulus
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, pc_tb);

    // Print header
    $display("Time\t reset next_pc    current_pc");
    $monitor("%0dns\t   %b    %h    %h", $time, reset, next_pc, current_pc);

    // --- 2a) Reset the PC ---
    reset   = 1;
    next_pc = 32'h00000000;
    #10;  // wait one clock
    reset = 0;

    // After reset, current_pc should be 0
    #10;

    // --- 2b) Sequential increments ---
    // Feed next_pc = PC+4
    next_pc = 32'h00000004;
    #10;
    next_pc = 32'h00000008;
    #10;

    // --- 2c) Branch target test ---
    next_pc = 32'h000000A0;
    #10;

    // Finish simulation
    #10;
    $finish;
  end

endmodule
