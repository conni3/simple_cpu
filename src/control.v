// src/control.v
// RISC-V RV32I single-cycle Control Unit
module control(
    input  wire [6:0] opcode,
    output reg        RegWrite,
    output reg        ALUSrc,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        MemtoReg,
    output reg        Branch,
    output reg [1:0]  ALUOp
);

  always @(*) begin
    // Default: all zeros (no-op)
    RegWrite  = 1'b0;
    ALUSrc    = 1'b0;
    MemRead   = 1'b0;
    MemWrite  = 1'b0;
    MemtoReg  = 1'b0;
    Branch    = 1'b0;
    ALUOp     = 2'b00;

    case (opcode)
      7'b0110011: begin  // R-type (add, sub, slt, etc.)
        RegWrite  = 1;
        ALUSrc    = 0;
        MemtoReg  = 0;
        MemRead   = 0;
        MemWrite  = 0;
        Branch    = 0;
        ALUOp     = 2'b10;
      end

      7'b0010011: begin  // I-type ALU (addi, slti, xori, etc.)
        RegWrite  = 1;
        ALUSrc    = 1;
        MemtoReg  = 0;
        MemRead   = 0;
        MemWrite  = 0;
        Branch    = 0;
        ALUOp     = 2'b10;  // feed funct3/funct7 into alu_control
      end

      7'b0000011: begin  // Load  (lw)
        RegWrite  = 1;
        ALUSrc    = 1;
        MemtoReg  = 1;
        MemRead   = 1;
        MemWrite  = 0;
        Branch    = 0;
        ALUOp     = 2'b00;  // ADD for address calculation
      end

      7'b0100011: begin  // Store (sw)
        RegWrite  = 0;
        ALUSrc    = 1;
        MemtoReg  = 1'bx;   // don't care
        MemRead   = 0;
        MemWrite  = 1;
        Branch    = 0;
        ALUOp     = 2'b00;  // ADD for address calculation
      end

      7'b1100011: begin  // Branch (beq, bne, ...)
        RegWrite  = 0;
        ALUSrc    = 0;
        MemtoReg  = 1'bx;   // don't care
        MemRead   = 0;
        MemWrite  = 0;
        Branch    = 1;
        ALUOp     = 2'b01;  // SUB for comparison
      end

      // (Optional) Jumps could be added here:
      // 7'b1101111: // JAL
      // 7'b1100111: // JALR

      default: begin
        // leave defaults
      end
    endcase
  end

endmodule
