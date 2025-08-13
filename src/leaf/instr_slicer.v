`timescale 1ns / 1ps

module instr_slicer (
    input wire [31:0] instr,

    output wire [6:0] opcode,  // instr[6:0]
    output wire [4:0] rd,      // instr[11:7]
    output wire [2:0] funct3,  // instr[14:12]
    output wire [4:0] rs1,     // instr[19:15]
    output wire [4:0] rs2,     // instr[24:20] (R/S/B types)
    output wire [6:0] funct7,  // instr[31:25] (R type)

    output wire [ 4:0] shamt,  // instr[24:20] (I-type shifts: SLLI/SRLI/SRAI)
    output wire [19:0] csr     // instr[31:20] (SYSTEM/CSR)
);
  assign opcode = instr[6:0];
  assign rd     = instr[11:7];
  assign funct3 = instr[14:12];
  assign rs1    = instr[19:15];
  assign rs2    = instr[24:20];
  assign funct7 = instr[31:25];

  // Convenience
  assign shamt  = instr[24:20];
  assign csr    = instr[31:20];
endmodule
