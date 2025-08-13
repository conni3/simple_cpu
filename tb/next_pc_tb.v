`timescale 1ns / 1ps
`define DATA_WIDTH 32

module next_pc_tb;

  // DUT inputs
  reg [`DATA_WIDTH-1:0] current_pc;
  reg [`DATA_WIDTH-1:0] imm_data;
  reg [`DATA_WIDTH-1:0] rs1_data;
  reg is_branch, is_jal, is_jalr, branch_taken;

  // DUT output
  wire [`DATA_WIDTH-1:0] next_pc;

  // Instantiate DUT
  next_pc dut (
      .current_pc(current_pc),
      .imm_data(imm_data),
      .rs1_data(rs1_data),
      .is_branch(is_branch),
      .is_jal(is_jal),
      .is_jalr(is_jalr),
      .branch_taken(branch_taken),
      .next_pc(next_pc)
  );

  integer failed, passed;

  task check;
    input [31:0] expected_value;
    input [8*64-1:0] label;
    begin
      #1;
      if (next_pc !== expected_value) begin
        
        $display("FAIL: %s  expected=%h got=%h", label, expected_value, next_pc);
        $fatal;
      end else begin
        $display("PASS: %s -> %h", label, next_pc);
      end
    end
  endtask

  initial begin
    current_pc   = 32'h0000_1000;
    rs1_data     = 32'h0000_2000;
    imm_data     = 32'h0000_0000;
    is_branch    = 1'b0;
    is_jal       = 1'b0;
    is_jalr      = 1'b0;
    branch_taken = 1'b0;

    // 1) pc + 4
    check(current_pc + 32'd4, "pc+4");

    // 2) Branch taken (imm pre-shifted)
    imm_data = 32'h0000_0020;
    is_branch = 1'b1;
    branch_taken = 1'b1;
    check(32'h0000_1000 + 32'h20, "branch taken");
    is_branch = 0;
    branch_taken = 0;
    imm_data = 0;

    // 3) JAL (imm pre-shifted)
    imm_data = 32'h0000_0040;
    is_jal = 1'b1;
    check(32'h0000_1000 + 32'h40, "JAL");
    is_jal   = 0;
    imm_data = 0;

    // 4) JALR: (rs1 + imm) with bit0 cleared
    rs1_data = 32'h0000_2004;
    imm_data = 32'h0000_0005;
    is_jalr  = 1'b1;
    check((rs1_data + imm_data) & ~32'b1, "JALR aligned");
    is_jalr = 0;
    imm_data = 0;

    // 5) Branch not taken -> pc+4
    is_branch = 1'b1;
    branch_taken = 1'b0;
    imm_data = 32'h0000_0100;
    check(32'h0000_1000 + 32'd4, "branch not taken");
    is_branch = 0;
    branch_taken = 0;
    imm_data = 0;

    // 6) Priority: JAL over branch
    is_branch = 1'b1;
    branch_taken = 1'b1;
    is_jal = 1'b1;
    imm_data = 32'h0000_0008;
    check(32'h0000_1000 + 32'h8, "priority JAL over branch");
    is_branch = 0;
    branch_taken = 0;
    is_jal = 0;
    imm_data = 0;

    // 7) Priority: JALR over others
    is_branch = 1'b1;
    branch_taken = 1'b1;
    is_jal = 1'b1;
    is_jalr = 1'b1;
    rs1_data = 32'h0000_3004;
    imm_data = 32'h0000_0001;  // 0x3005 -> 0x3004
    check((rs1_data + imm_data) & ~32'b1, "priority JALR");
    is_branch = 0;
    branch_taken = 0;
    is_jal = 0;
    is_jalr = 0;

    $display("All tests passed.");
    $finish;
  end

endmodule
