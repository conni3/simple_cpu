`timescale 1ns / 1ps

module data_mem (
    input  wire        clk,
    input  wire        mem_write,
    input  wire        mem_read,
    input  wire [10:0] addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata
);

  reg [31:0] mem[(1<<11)-1:0];

  always @(posedge clk) begin
    if (mem_write) begin
      mem[addr] <= wdata;
    end
    rdata <= mem[addr];
  end

endmodule
