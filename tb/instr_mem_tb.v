`timescale 1ps / 1ps
`include "defines.vh"

module instr_mem_tb;

  reg  [10:0] addr;
  wire [31:0] instr;


  instr_mem uut (
      .addr (addr),
      .instr(instr)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, instr_mem_tb);

    addr = 11'h000;
    #10;

    if (instr !== 32'h00000013) begin
      $display("Test failed: Expected instruction at address %h to be 0x00000000, got %h", addr,
               instr);
    end else begin
      $display("Test passed: Instruction at address %h is %h", addr, instr);
    end

    addr = 11'h001;
    #10;

    if (instr !== 32'h00000023) begin
      $display("Test failed: Expected instruction at address %h to be 0x00000001, got %h", addr,
               instr);
    end else begin
      $display("Test passed: Instruction at address %h is %h", addr, instr);
    end

    addr = 11'h002;
    #10;

    if (instr !== 32'h00000012) begin
      $display("Test failed: Expected instruction at address %h to be 0x00000010, got %h", addr,
               instr);
    end else begin
      $display("Test passed: Instruction at address %h is %h", addr, instr);
    end

    $finish;
  end

endmodule
