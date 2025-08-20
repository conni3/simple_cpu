`timescale 1ps / 1ps

module regfile (
    input  wire        clk,
    input  wire        reset,
    input  wire        reg_write,
    input  wire [ 4:0] rs1,
    input  wire [ 4:0] rs2,
    input  wire [ 4:0] rd,
    input  wire [31:0] rd_wdata,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);

  reg [31:0] regs[31:0];
  integer i;

  // synchronous reset, write x0 blocked
  always @(posedge clk) begin
    if (reset) begin
      for (i = 0; i < 32; i = i + 1) regs[i] <= 32'b0;
    end else if (reg_write && (rd != 5'd0)) begin
      regs[rd] <= rd_wdata;
    end
  end

  // asynchronous reads, x0 hard-wired to 0
  assign rs1_data = (rs1 != 5'd0) ? regs[rs1] : 32'b0;
  assign rs2_data = (rs2 != 5'd0) ? regs[rs2] : 32'b0;

endmodule
