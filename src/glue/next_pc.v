`timescale 1ps / 1ps
`include "defines.vh"

module next_pc (
    input  wire [`DATA_WIDTH-1:0] pc_current,
    input  wire [`DATA_WIDTH-1:0] imm_out,       // B/J: offset<<1 from imm_gen; JALR: unshifted
    input  wire [`DATA_WIDTH-1:0] rs1_data,
    input  wire                   is_branch,
    input  wire                   is_jal,
    input  wire                   is_jalr,
    input  wire                   branch_taken,
    output wire [`DATA_WIDTH-1:0] pc_next
);

  wire [`DATA_WIDTH-1:0] pc_plus4 = pc_current + 4;
  wire [`DATA_WIDTH-1:0] branch_jal_pc = pc_current + imm_out;  // (PC + offset)
  wire [`DATA_WIDTH-1:0] jalr_raw = rs1_data + imm_out;  // (rs1 + imm)
  wire [`DATA_WIDTH-1:0] jalr_aligned = {jalr_raw[`DATA_WIDTH-1:1], 1'b0};  // clear bit 0

  assign pc_next =
      is_jalr                     ? jalr_aligned  :
      is_jal                      ? branch_jal_pc :
      (is_branch && branch_taken) ? branch_jal_pc :
                                    pc_plus4;

  wire misalign_bits = !$isunknown(pc_current[1:0]) && !$isunknown(pc_next[1:0]);

`ifndef SYNTHESIS
  always @(*) begin
    if (misalign_bits) begin
      #1;
      if (pc_current[1:0] != 2'b00 || pc_next[1:0] != 2'b00)
        $fatal(1, "Instr addr misaligned: pc=%h next=%h", pc_current, pc_next);
    end
  end
`endif
endmodule
