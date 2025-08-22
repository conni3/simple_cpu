`timescale 1ns / 1ps

module instr_mem #(
    parameter integer ADDR_WIDTH = 11,
    parameter MEM_FILE = "src/instr_mem.mem"
) (
    input  wire [ADDR_WIDTH-1:0] addr,
    output reg  [          31:0] instr
);

  reg [31:0] mem[0:(1<<ADDR_WIDTH)-1];

  initial begin
    $readmemh(MEM_FILE, mem);
  end

  always @* begin
    instr = mem[addr];
  end

endmodule
