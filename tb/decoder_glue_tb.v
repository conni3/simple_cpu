`timescale 1ns / 1ps
`include "include/defines.vh"

module decoder_glue_tb;

  // ---- DUT I/O ----
  reg [31:0] instr;
  wire [4:0] rd, rs1, rs2;
  wire [31:0] imm;
  wire regWrite, MemRead, MemWrite, ALUSrc, BranchSig, Jump;
  wire [1:0] ALUOp, wb_sel;
  wire [2:0] ImmSrc;
  wire JAL, JALR, Branch;

  // Instantiate DUT (your wrapper that instantiates decoder/control/imm_gen)
  decoder_glue dut (
      .instr(instr),
      .rd(rd),
      .rs1(rs1),
      .rs2(rs2),
      .imm(imm),
      .regWrite(regWrite),
      .MemRead(MemRead),
      .MemWrite(MemWrite),
      .ALUSrc(ALUSrc),
      .BranchSig(BranchSig),
      .Jump(Jump),
      .ALUOp(ALUOp),
      .ImmSrc(ImmSrc),
      .wb_sel(wb_sel),
      .JAL(JAL),
      .JALR(JALR),
      .Branch(Branch)
  );

  // ---- Local encodings (standard RV32I) ----
  localparam [6:0] OPC_RTYPE = 7'b0110011;
  localparam [6:0] OPC_ITYPE = 7'b0010011;
  localparam [6:0] OPC_LOAD = 7'b0000011;
  localparam [6:0] OPC_STORE = 7'b0100011;
  localparam [6:0] OPC_BRANCH = 7'b1100011;
  localparam [6:0] OPC_JAL = 7'b1101111;
  localparam [6:0] OPC_JALR = 7'b1100111;
  localparam [6:0] OPC_LUI = 7'b0110111;
  localparam [6:0] OPC_AUIPC = 7'b0010111;

  // ---- Builders (encode instructions) ----
  function automatic [31:0] mk_r(input [6:0] funct7, input [4:0] rs2, input [4:0] rs1,
                                 input [2:0] funct3, input [4:0] rd);
    mk_r = {funct7, rs2, rs1, funct3, rd, OPC_RTYPE};
  endfunction

  function automatic [31:0] mk_i(input integer imm12, input [4:0] rs1, input [2:0] funct3,
                                 input [4:0] rd, input [6:0] opc);
    mk_i = {{20{imm12[11]}}, imm12[11:0], rs1, funct3, rd, opc};
  endfunction

  function automatic [31:0] mk_s(input integer imm12, input [4:0] rs2, input [4:0] rs1,
                                 input [2:0] funct3);
    mk_s = {{20{imm12[11]}}, imm12[11:5], rs2, rs1, funct3, imm12[4:0], OPC_STORE};
  endfunction

  function automatic [31:0] mk_b(input integer imm13, input [4:0] rs2, input [4:0] rs1,
                                 input [2:0] funct3);
    // imm13 is byte offset; bit0 must be 0 (halfword aligned)
    mk_b = {
      {19{imm13[12]}}, imm13[12], imm13[10:5], rs2, rs1, funct3, imm13[4:1], imm13[11], OPC_BRANCH
    };
  endfunction

  function automatic [31:0] mk_u(input integer imm20, input [4:0] rd, input [6:0] opc);
    // imm20 is upper 20 bits (value << 12)
    mk_u = {imm20[19:0], rd, opc};
  endfunction

  function automatic [31:0] mk_j(input integer imm21, input [4:0] rd);
    // imm21 is byte offset; bit0 must be 0
    mk_j = {{11{imm21[20]}}, imm21[20], imm21[10:1], imm21[11], imm21[19:12], rd, OPC_JAL};
  endfunction

  // ---- Check helpers ----
  task automatic chk(input bit cond, input string msg);
    if (!cond) $fatal(1, "FAIL: %s", msg);
  endtask
  task automatic settle;
    #1;
  endtask

  // ---- Tests ----
  initial begin
    $display("Start decoder_glue tests...");

    // R-type: add x5 = x1 + x2
    instr = mk_r(7'b0000000, 5'd2, 5'd1, 3'b000, 5'd5);
    settle();
    chk(rd == 5 && rs1 == 1 && rs2 == 2, "R-type slicer");
    chk(regWrite && !ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "R-type controls");
    chk(ALUOp == 2'b10, "R-type ALUOp");
    chk(wb_sel == 2'd0, "R-type wb_sel=ALU");
    chk(imm == 32'd0, "R-type imm default 0");

    // I-type ALU: addi x6 = x1 + 0x7F
    instr = mk_i(12'h07F, 5'd1, 3'b000, 5'd6, OPC_ITYPE);
    settle();
    chk(rd == 6 && rs1 == 1, "I-type slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "I-type controls");
    chk(ALUOp == 2'b10, "I-type ALUOp");
    chk(wb_sel == 2'd0, "I-type wb_sel=ALU");
    chk(imm == 32'h0000007F, "I-type imm value");

    // LOAD: lw x7, 24(x3)
    instr = mk_i(12'd24, 5'd3, 3'b010, 5'd7, OPC_LOAD);
    settle();
    chk(rd == 7 && rs1 == 3, "LOAD slicer");
    chk(regWrite && ALUSrc && MemRead && !MemWrite && !BranchSig && !Jump, "LOAD controls");
    chk(ALUOp == 2'b00, "LOAD ALUOp (addr add)");
    chk(wb_sel == 2'd1, "LOAD wb_sel=MEM");
    chk(imm == 32'd24, "LOAD imm I-type");

    // STORE: sw x8, 28(x4)
    instr = mk_s(12'd28, 5'd8, 5'd4, 3'b010);
    settle();
    chk(rs1 == 4 && rs2 == 8, "STORE slicer");
    chk(!regWrite && ALUSrc && !MemRead && MemWrite && !BranchSig && !Jump, "STORE controls");
    chk(ALUOp == 2'b00, "STORE ALUOp (addr add)");
    chk(wb_sel == 2'd0, "STORE wb_sel=ALU (ignored)");
    chk(imm == 32'd28, "STORE imm S-type");

    // BRANCH: beq x1, x2, +16
    instr = mk_b(13'd16, 5'd2, 5'd1, 3'b000);
    settle();
    chk(rs1 == 1 && rs2 == 2, "BRANCH slicer");
    chk(!regWrite && !ALUSrc && !MemRead && !MemWrite && BranchSig && !Jump, "BRANCH controls");
    chk(ALUOp == 2'b01, "BRANCH ALUOp");
    chk(wb_sel == 2'd0, "BRANCH wb_sel=ALU (ignored)");
    chk(imm == 32'd16, "BRANCH imm B-type");

    // JAL: x1 <- PC+4, jump +32
    instr = mk_j(21'd32, 5'd1);
    settle();
    chk(rd == 1, "JAL slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && Jump, "JAL controls");
    chk(wb_sel == 2'd2 && JAL && !JALR, "JAL wb_sel=PC+4");
    chk(imm == 32'd32, "JAL imm J-type");

    // JALR: x5 <- PC+4, jump rs1+20
    instr = mk_i(12'd20, 5'd9, 3'b000, 5'd5, OPC_JALR);
    settle();
    chk(rd == 5 && rs1 == 9, "JALR slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && Jump, "JALR controls");
    chk(wb_sel == 2'd2 && !JAL && JALR, "JALR wb_sel=PC+4");
    chk(imm == 32'd20, "JALR imm I-type");

    // LUI: x10 <- Uimm
    // imm = 0x12345_000
    instr = mk_u(20'h12345, 5'd10, OPC_LUI);
    settle();
    chk(rd == 10, "LUI slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "LUI controls");
    chk(ALUOp == 2'b11, "LUI ALUOp");
    chk(wb_sel == 2'd0, "LUI wb_sel=ALU");
    chk(imm == 32'h12345_000, "LUI imm U-type");

    // AUIPC: x11 <- PC + Uimm
    instr = mk_u(20'h01234, 5'd11, OPC_AUIPC);
    settle();
    chk(rd == 11, "AUIPC slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "AUIPC controls");
    chk(ALUOp == 2'b00, "AUIPC ALUOp (PC+imm via ALU path)");
    chk(wb_sel == 2'd0, "AUIPC wb_sel=ALU");
    chk(imm == 32'h01234_000, "AUIPC imm U-type");

    $display("All decoder_glue tests passed.");
    $finish;
  end

endmodule
