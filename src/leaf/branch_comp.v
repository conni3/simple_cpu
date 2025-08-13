module branch_comp (
    input  wire [31:0] op1,
    input  wire [31:0] op2,
    input  wire [ 2:0] funct3,
    output reg         branch
);


  localparam BEQ = 3'b000;  // Branch if equal
  localparam BNE = 3'b001;  // Branch if not equal
  localparam BLT = 3'b100;  // Branch if less than (signed)
  localparam BGE = 3'b101;  // Branch if greater than or equal (signed)
  localparam BLTU = 3'b110;  // Branch if less than (unsigned)
  localparam BGEU = 3'b111;  // Branch if greater than or equal (unsigned)

  always @(*) begin
    case (funct3)
      BEQ: branch = (op1 == op2);
      BNE: branch = (op1 != op2);
      BLT: branch = ($signed(op1) < $signed(op2));
      BGE: branch = ($signed(op1) >= $signed(op2));
      BLTU: branch = (op1 < op2);
      BGEU: branch = (op1 >= op2);
      default: branch = 1'b0;
    endcase
  end

endmodule
