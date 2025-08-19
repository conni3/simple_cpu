`timescale 1ps / 1ps
`include "defines.vh"

module pc (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] next_pc,
    output reg  [31:0] current_pc
);

  always @(posedge clk or posedge reset) begin
    if (reset) current_pc <= 32'b0;
    else current_pc <= next_pc;
  end

endmodule
