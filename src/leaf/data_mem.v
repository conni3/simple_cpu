`timescale 1ns / 1ps

module data_mem #(
    parameter integer ADDR_WIDTH = 11,
    parameter MEM_FILE = "src/data_mem.mem"
) (
    input  wire                  clk,
    input  wire                  mem_write,
    input  wire                  mem_read,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [          31:0] wdata,
    output reg  [          31:0] rdata
);

  reg [31:0] mem[0:(1<<ADDR_WIDTH)-1];
  initial begin
    $readmemh(MEM_FILE, mem);
  end

  always @(posedge clk) begin
    if (mem_write) begin
      mem[addr] <= wdata;
    end
  end

  always @* begin
    rdata = mem_read ? mem[addr] : 32'b0;
  end

endmodule
