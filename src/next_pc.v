`timescale 1ps/1ps
`include "include/defines.vh"

module next_pc (
    input wire [DATA_WIDTH-1:0] current_pc,
    input wire [DATA_WIDTH-1:0] imm_data,
    input wire [DATA_WIDTH-1:0] rs1_data,
    input wire is_branch,
    input wire is_jaL,
    input wire is_jalr,
    input wire branch_taken,
    output wire [DATA_WIDTH-1:0] next_pc
)
    wire [DATA_WIDTH-1:0] pc_plus4 = current_pc + 4;
    wire [DATA_WIDTH-1:0] branch_jal_pc = pc + imm_data;
    wire [DATA_WIDTH-1:0] jalr_pc = {rs1_data + imm_data, 1'b0};


endmodule
