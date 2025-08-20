`timescale 1ns / 1ps
`include "defines.vh"

module alu (
    input  wire [31:0] op_a,
    input  wire [31:0] op_b,
    input  wire [ 3:0] alu_ctrl,
    output reg  [31:0] alu_result,
    output wire        alu_zero
);

  assign alu_zero = (alu_result == 32'b0);

  always @(*) begin
    case (alu_ctrl)
      `ALU_ADD:  alu_result = op_a + op_b;
      `ALU_SUB:  alu_result = op_a - op_b;
      `ALU_SLL:  alu_result = op_a << op_b[4:0];
      `ALU_SLT:  alu_result = ($signed(op_a) < $signed(op_b)) ? 32'd1 : 32'd0;
      `ALU_SLTU: alu_result = (op_a < op_b) ? 32'd1 : 32'd0;
      `ALU_XOR:  alu_result = op_a ^ op_b;
      `ALU_SRL:  alu_result = op_a >> op_b[4:0];
      `ALU_SRA:  alu_result = $signed(op_a) >>> op_b[4:0];
      `ALU_OR:   alu_result = op_a | op_b;
      `ALU_AND:  alu_result = op_a & op_b;
      default:   alu_result = 32'd0;
    endcase
  end

endmodule
