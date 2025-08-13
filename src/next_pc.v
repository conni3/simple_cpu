`timescale 1ps / 1ps
`include "include/defines.vh"

module next_pc (
    input wire [`DATA_WIDTH-1:0] current_pc,
    input wire [`DATA_WIDTH-1:0] imm_data,  // B/J: offset<<1 provided by imm unit; JALR: unshifted
    input wire [`DATA_WIDTH-1:0] rs1_data,
    input wire is_branch,
    input wire is_jal,
    input wire is_jalr,
    input wire branch_taken,
    output wire [`DATA_WIDTH-1:0] next_pc
);

  wire [`DATA_WIDTH-1:0] pc_plus4 = current_pc + 4;
  wire [`DATA_WIDTH-1:0] branch_jal_pc = current_pc + imm_data;  // (PC + offset)
  wire [`DATA_WIDTH-1:0] jalr_raw = rs1_data + imm_data;  // (rs1 + imm)
  wire [`DATA_WIDTH-1:0] jalr_aligned = {jalr_raw[`DATA_WIDTH-1:1], 1'b0};  // clear bit 0

  assign next_pc =
      is_jalr                     ? jalr_aligned  :
      is_jal                      ? branch_jal_pc :
      (is_branch && branch_taken) ? branch_jal_pc :
                                   pc_plus4;

  wire misalign_pc = (current_pc[1:0] != 2'b00) || next_pc[1:0] != 2'b00;

`ifndef SYNTHESIS
  always @(*)
    if (misalign_pc)
      $fatal(1, "Instr addr misaligned: pc=%h next=%h", current_pc, next_pc);
`endif
endmodule

