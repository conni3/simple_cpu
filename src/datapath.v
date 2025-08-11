`timescale 1ns / 1ps

//brooo wtf is this, it should be rtl

module tb_datapath_wrapper;
  reg clk;
  reg reset;

  datapath_wrapper dut (
      .clk_0  (clk),
      .reset_0(reset)
  );


  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin

    $dumpfile("dump.vcd");
    $dumpvars(0, tb_datapath_wrapper);

    reset = 1;
    #30;
    reset = 0;

    #1000;
    $finish;
  end

  always @(posedge clk) begin

    $display("T=%0t | PC=%h | instr=%h | alu_out=%h", $time, dut.datapath_i.pc_reg,
             dut.datapath_i.instr, dut.datapath_i.alu_out);
  end

endmodule
