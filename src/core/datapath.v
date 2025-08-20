`timescale 1ps/1ps
`include "defines.vh"

module datapath (
    input  wire [`DATA_WIDTH-1:0] pc_current,
    input  wire [`DATA_WIDTH-1:0] imm_out,       // B/J: offset<<1 from imm_gen; JALR: unshifted
    input  wire [`DATA_WIDTH-1:0] rs1_data,
    input  wire                   is_branch,
    input  wire                   is_jal,
    input  wire                   is_jalr,
    input  wire                   branch_taken,

    output wire [`DATA_WIDTH-1:0] pc_next
);
