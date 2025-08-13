`timescale 1ps / 1ps

module reg_file (
    input  wire        clk,
    input  wire        reset,
    input  wire        regwrite,
    input  wire [ 4:0] read_reg1,
    input  wire [ 4:0] read_reg2,
    input  wire [ 4:0] write_reg,
    input  wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);


  reg [31:0] regs[31:0];
  integer i;


  always @(posedge clk) begin
    if (reset) begin

      for (i = 0; i < 32; i = i + 1) regs[i] <= 32'b0;
    end else if (regwrite && (write_reg != 5'd0)) begin

      regs[write_reg] <= write_data;
    end
  end


  assign read_data1 = (read_reg1 != 5'd0) ? regs[read_reg1] : 32'b0;
  assign read_data2 = (read_reg2 != 5'd0) ? regs[read_reg2] : 32'b0;

endmodule
