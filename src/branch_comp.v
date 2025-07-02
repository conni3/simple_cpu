// src/branch_comp.v
module branch_comp #(
    parameter DATA_WIDTH = 32
)(
    input  wire [DATA_WIDTH-1:0] op1,     // first operand (rs1)
    input  wire [DATA_WIDTH-1:0] op2,     // second operand (rs2)
    input  wire [2:0]            funct3,  // branch type from control unit
    output reg                   branch   // branch-taken flag
);

    always @(*) begin
        case (funct3)
            3'b000: branch = (op1 == op2);                                // BEQ
            3'b001: branch = (op1 != op2);                                // BNE
            3'b100: branch = ($signed(op1) <  $signed(op2));            // BLT
            3'b101: branch = ($signed(op1) >= $signed(op2));            // BGE
            3'b110: branch = (op1 < op2);                                // BLTU
            3'b111: branch = (op1 >= op2);                               // BGEU
            default: branch = 1'b0;                                       // no branch
        endcase
    end

endmodule
