`timescale 1ns / 1ps
`include "include/defines.vh"

module decoder #(
    parameter DATA_WIDTH = 32
) (
    input wire [DATA_WIDTH-1:0] instr,
    output wire ALUreg,
    output wire regWrite,
    output wire JAL,
    output wire JALR,
    output wire Branch,
    output wire LUI,
    output wire AUIPC,
    output wire ALUimm,
    output wire Load,
    output wire Store,
    output wire SYSTEM
);


  wire [6:0] opcode = instr[6:0];

  assign ALUreg =  (opcode == `OP_RTYPE); // rd <- rs1 OP rs2   
  assign ALUimm =  (opcode == `OP_ITYPE); // rd <- rs1 OP Iimm
  assign Branch =  (opcode == `OP_BRANCH); // if(rs1 OP rs2) PC<-PC+Bimm
  assign JALR   =  (opcode == `OP_JALR && instr[14:12] == 3'b000); // rd <- PC+4; PC<-rs1+Iimm
  assign JAL    =  (opcode == `OP_JAL); // rd <- PC+4; PC<-PC+Jimm
  assign AUIPC  =  (opcode == `OP_AUIPC); // rd <- PC + Uimm
  assign LUI    =  (opcode == `OP_LUI); // rd <- Uimm   
  assign Load   =  (opcode == `OP_LOAD); // rd <- mem[rs1+Iimm]
  assign Store  =  (opcode == `OP_STORE); // mem[rs1+Simm] <- rs2
  assign SYSTEM =  (opcode == `OP_SYSTEM); // special

  assign regWrite = ALUreg || ALUimm || Load || LUI || AUIPC || JAL || JALR;

endmodule
