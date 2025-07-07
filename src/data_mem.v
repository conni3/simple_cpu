`timescale 1ns / 1ps

module data_mem (
    input  wire        clk,
    input  wire        we,
    input  wire        re,
    input  wire [10:0] addr,
    input  wire [31:0] write_data,
    output reg  [31:0] read_data
);

  reg [31:0] mem[(1<<11)-1:0];

  always @(posedge clk) begin
    if (we) begin
      mem[addr] <= write_data;
    end
    read_data <= mem[addr];
  end

endmodule
