`timescale 1ns / 1ps


`define MEM_FILE "src/instr_mem.mem"
module instr_mem (
    input  wire [10:0] addr,
    output reg  [31:0] instr
);

  reg [31:0] mem[(1<<11)-1:0];

  initial begin
    $readmemb(`MEM_FILE, mem);
  end

  always @(*) begin
    instr = mem[addr];
  end

endmodule
