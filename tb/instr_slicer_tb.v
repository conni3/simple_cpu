// tb/instr_slicer_tb.sv
`timescale 1ns / 1ps

`define CHECK(X) assert(X) else begin \
  $error("ASSERT FAILED: %s  instr=0x%08x  t=%0t", `"X`", instr, $time); \
  $fatal; \
end

module instr_slicer_tb;
  // DUT I/O
  reg [31:0] instr;
  wire [6:0] opcode, funct7;
  wire [4:0] rd, rs1, rs2, shamt;
  wire [ 2:0] funct3;
  wire [19:0] csr;

  // DUT
  instr_slicer dut (
      .instr(instr),
      .opcode(opcode),
      .rd(rd),
      .funct3(funct3),
      .rs1(rs1),
      .rs2(rs2),
      .funct7(funct7),
      .shamt(shamt),
      .csr(csr)
  );

  // Encoders (just to pack fields per format)
  function automatic [31:0] enc_r(input [6:0] f7, input [4:0] r2, r1, input [2:0] f3,
                                  input [4:0] rd_, input [6:0] opc);
    enc_r = {f7, r2, r1, f3, rd_, opc};
  endfunction

  function automatic [31:0] enc_i(input [11:0] imm12, input [4:0] r1, input [2:0] f3,
                                  input [4:0] rd_, input [6:0] opc);
    enc_i = {imm12, r1, f3, rd_, opc};
  endfunction

  function automatic [31:0] enc_s(input [11:0] imm12, input [4:0] r2, r1, input [2:0] f3,
                                  input [6:0] opc);
    enc_s = {imm12[11:5], r2, r1, f3, imm12[4:0], opc};
  endfunction

  function automatic [31:0] enc_b(input [12:0] off, input [4:0] r2, r1, input [2:0] f3,
                                  input [6:0] opc);
    // off[0] is implied 0 in real encoding; we pass 13 bits and place them.
    enc_b = {off[12], off[10:5], r2, r1, f3, off[4:1], off[11], opc};
  endfunction

  function automatic [31:0] enc_u(input [19:0] imm20, input [4:0] rd_, input [6:0] opc);
    enc_u = {imm20, rd_, opc};
  endfunction

  function automatic [31:0] enc_j(input [20:0] off, input [4:0] rd_, input [6:0] opc);
    // Place as J-type (off[0] implied 0)
    enc_j = {off[20], off[10:1], off[11], off[19:12], rd_, opc};
  endfunction

  task automatic check_raw_bits;
    // The slicer must match the bitfields exactly
    begin
      #1;
      `CHECK(opcode == instr[6:0]);
      `CHECK(rd == instr[11:7]);
      `CHECK(funct3 == instr[14:12]);
      `CHECK(rs1 == instr[19:15]);
      `CHECK(rs2 == instr[24:20]);
      `CHECK(funct7 == instr[31:25]);
      `CHECK(shamt == instr[24:20]);
      `CHECK(csr == instr[31:20]);
    end
  endtask

  initial begin
    // R-type (e.g., SUB shape)
    instr = enc_r(7'h20, 5'd3, 5'd2, 3'h0, 5'd1, 7'h33);
    check_raw_bits();

    // I-type (ADDI shape)
    instr = enc_i(12'h4a5, 5'd8, 3'h2, 5'd9, 7'h13);
    check_raw_bits();

    // I-type shift (SRLI/SRAI shape -> shamt tap)
    instr = enc_i({7'h00, 5'd12}, 5'd1, 3'h5, 5'd7, 7'h13);  // imm[11:5]=0, shamt=12
    check_raw_bits();
    `CHECK(shamt == 5'd12);

    // S-type (SW shape) — rd carries imm[4:0] bits in this layout
    instr = enc_s(12'h2b6, 5'd7, 5'd6, 3'h2, 7'h23);
    check_raw_bits();

    // B-type (BEQ shape) — ensures rs1/rs2/f3 placements
    instr = enc_b(13'h1A2, 5'd11, 5'd10, 3'h0, 7'h63);
    check_raw_bits();

    // U-type (LUI shape)
    instr = enc_u(20'h12345, 5'd1, 7'h37);
    check_raw_bits();

    // J-type (JAL shape)
    instr = enc_j(21'h1_E7AD, 5'd5, 7'h6f);
    check_raw_bits();

    // SYSTEM/CSR (opcode 0x73): test csr tap
    instr = enc_i(12'habc, 5'd3, 3'h1, 5'd4, 7'h73);
    check_raw_bits();
    `CHECK(csr == 20'h00abc);  // upper 8 bits zero; csr is instr[31:20]

    // Edge patterns
    instr = 32'h0000_0000;
    check_raw_bits();
    instr = 32'hFFFF_FFFF;
    check_raw_bits();

    // Randomized smoke (verifies wiring equivalence)
    repeat (200) begin
      instr = $urandom();
      check_raw_bits();
    end

    $display("All instr_slicer assertions PASSED.");
    $finish;
  end
endmodule
