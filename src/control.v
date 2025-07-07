`include "include/defines.vh"

module control (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    output reg        RegWrite,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        MemtoReg,
    output reg        ALUSrc,
    output reg        Branch,
    output reg        Jump,
    output reg  [1:0] ALUOp,
    output reg  [2:0] ImmSrc
);

  always @(*) begin

    RegWrite = 1'b0;
    MemRead  = 1'b0;
    MemWrite = 1'b0;
    MemtoReg = 1'b0;
    ALUSrc   = 1'b0;
    Branch   = 1'b0;
    Jump     = 1'b0;
    ALUOp    = 2'b00;
    ImmSrc   = 3'b000;

    case (opcode)
      `OP_RTYPE: begin
        RegWrite = 1'b1;
        ALUOp    = 2'b10;
      end

      `OP_ITYPE: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b10;
        ImmSrc   = `Imm_I;
      end

      `OP_LOAD: begin
        RegWrite = 1'b1;
        MemRead  = 1'b1;
        MemtoReg = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b00;
        ImmSrc   = `Imm_I;
      end

      `OP_STORE: begin
        MemWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b00;
        ImmSrc   = `Imm_S;
      end

      `OP_BRANCH: begin
        Branch = 1'b1;
        ALUOp  = 2'b01;
        ImmSrc = `Imm_B;
      end

      `OP_JAL: begin
        ALUSrc   = 1'b1;
        RegWrite = 1'b1;
        Jump     = 1'b1;
        ALUOp    = 2'b00;
        ImmSrc   = `Imm_J;
      end


      `OP_JALR: begin
        if (funct3 == 3'b000) begin
          ALUSrc   = 1'b1;
          RegWrite = 1'b1;
          Jump     = 1'b1;
          ALUOp    = 2'b00;
          ImmSrc   = `Imm_I;
        end
      end

      `OP_LUI: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b11;
        ImmSrc   = `Imm_U;
      end

      `OP_AUIPC: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b00;
        ImmSrc   = `Imm_U;
      end



      default: begin
      end
    endcase
  end

endmodule
