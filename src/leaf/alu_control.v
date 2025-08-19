`timescale 1ps / 1ps
`include "defines.vh"

module alu_control (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire       funct7_5,
    output reg  [3:0] ALUCtrl
);

  // ALU Control Signals


  always @(*) begin
    case (ALUOp)
      2'b00: ALUCtrl = `ALU_ADD;
      2'b01: ALUCtrl = `ALU_SUB;
      2'b11: ALUCtrl = `ALU_LUI;
      2'b10: begin
        case ({
          funct7_5, funct3
        })
          4'b0_000: ALUCtrl = `ALU_ADD;
          4'b1_000: ALUCtrl = `ALU_SUB;
          4'b0_001: ALUCtrl = `ALU_SLL;
          4'b0_010: ALUCtrl = `ALU_SLT;
          4'b0_011: ALUCtrl = `ALU_SLTU;
          4'b0_100: ALUCtrl = `ALU_XOR;
          4'b0_101: ALUCtrl = `ALU_SRL;
          4'b1_101: ALUCtrl = `ALU_SRA;
          4'b0_110: ALUCtrl = `ALU_OR;
          4'b0_111: ALUCtrl = `ALU_AND;
          default:  ALUCtrl = `ALU_ADD;
        endcase
      end
    endcase
  end
endmodule
