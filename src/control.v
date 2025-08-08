`include "include/defines.vh"

module control #(
    parameter DATA_WIDTH = 32
) (
    input  wire [DATA_WIDTH-1:0] instr,
    input  wire                  ALUreg,
    input  wire                  ALUimm,
    input  wire                  Branch,
    input  wire                  JAL,
    input  wire                  JALR,
    input  wire                  LUI,
    input  wire                  AUIPC,
    input  wire                  Load,
    input  wire                  Store,
    input  wire                  SYSTEM,
    output reg                   MemRead,
    output reg                   MemWrite,
    output reg                   MemtoReg,
    output reg                   ALUSrc,
    output reg                   BranchSig,
    output reg                   Jump,
    output reg  [           1:0] ALUOp,
    output reg  [           2:0] ImmSrc
);

  wire funct3 = instr[14:12];

  always @(*) begin

    MemRead   = 1'b0;
    MemWrite  = 1'b0;
    MemtoReg  = 1'b0;
    ALUSrc    = 1'b0;
    BranchSig = 1'b0;
    Jump      = 1'b0;
    ALUOp     = 2'b00;
    ImmSrc    = 3'b000;

    if (ALUreg) begin
      ALUOp = 2'b10;  // R-type
    end

    if (ALUimm) begin
      ALUSrc = 1'b1;  // I-type
      ALUOp  = 2'b10;
      ImmSrc = `Imm_I;
    end

    if (Load) begin
      MemRead  = 1'b1;
      MemtoReg = 1'b1;
      ALUSrc   = 1'b1;
      ALUOp    = 2'b00;
      ImmSrc   = `Imm_I;
    end

    if (Store) begin
      MemWrite = 1'b1;
      ALUSrc   = 1'b1;
      ALUOp    = 2'b00;
      ImmSrc   = `Imm_S;
    end

    if (Branch) begin
      BranchSig = 1'b1;
      ALUOp = 2'b01;
      ImmSrc = `Imm_B;
    end

    if (JAL) begin
      ALUSrc = 1'b1;
      Jump   = 1'b1;
      ALUOp  = 2'b00;
      ImmSrc = `Imm_J;
    end

    if (JALR) begin
      ALUSrc = 1'b1;
      Jump   = 1'b1;
      ALUOp  = 2'b00;
      ImmSrc = `Imm_I;
    end

    if (LUI) begin
      ALUSrc = 1'b1;
      ALUOp  = 2'b11;
      ImmSrc = `Imm_U;
    end

    if (AUIPC) begin
      ALUSrc = 1'b1;
      ALUOp  = 2'b00;
      ImmSrc = `Imm_U;
    end

    if (SYSTEM) begin
      // not done yet
    end

  end

endmodule
