`timescale 1ps / 1ps
`include "defines.vh"

module alu_control (
    input  wire [1:0] alu_op,
    input  wire [2:0] funct3,
    input  wire       funct7_5,
    output reg  [3:0] alu_ctrl
);

  // ALU Control Signals


  always @(*) begin
    case (alu_op)
      2'b00: alu_ctrl = `ALU_ADD;
      2'b01: alu_ctrl = `ALU_SUB;
      2'b11: alu_ctrl = `ALU_LUI;
      2'b10: begin
        case ({
          funct7_5, funct3
        })
          4'b0_000: alu_ctrl = `ALU_ADD;
          4'b1_000: alu_ctrl = `ALU_SUB;
          4'b0_001: alu_ctrl = `ALU_SLL;
          4'b0_010: alu_ctrl = `ALU_SLT;
          4'b0_011: alu_ctrl = `ALU_SLTU;
          4'b0_100: alu_ctrl = `ALU_XOR;
          4'b0_101: alu_ctrl = `ALU_SRL;
          4'b1_101: alu_ctrl = `ALU_SRA;
          4'b0_110: alu_ctrl = `ALU_OR;
          4'b0_111: alu_ctrl = `ALU_AND;
          default:  alu_ctrl = `ALU_ADD;
        endcase
      end
    endcase
  end
endmodule
