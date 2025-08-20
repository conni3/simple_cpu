`timescale 1ps / 1ps
`include "defines.vh"

module imm_gen (
    input  wire [31:0] instr,
    input  wire [ 2:0] imm_sel,
    output reg  [31:0] imm_out
);
  wire [31:0] i_imm = {{20{instr[31]}}, instr[31:20]};
  wire [31:0] s_imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
  wire [31:0] b_imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
  wire [31:0] u_imm = {instr[31:12], 12'b0};
  wire [31:0] j_imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

  always @(*) begin
    case (imm_sel)
      `Imm_I: imm_out = i_imm;
      `Imm_S: imm_out = s_imm;
      `Imm_B: imm_out = b_imm;
      `Imm_U: imm_out = u_imm;
      `Imm_J: imm_out = j_imm;
      `Imm_NONE: imm_out = 32'b0;
      default: imm_out = 32'b0;
    endcase
  end
endmodule
