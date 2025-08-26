`timescale 1ns / 1ps
`include "defines.vh"

module decoder_glue_tb;

  // ---- DUT I/O ----
  reg [31:0] instr;
  wire [4:0] rd, rs1, rs2;
  wire [31:0] imm;
  wire regWrite, MemRead, MemWrite, ALUSrc, BranchSig, Jump;
  wire [1:0] ALUOp, wb_sel;
  wire [2:0] ImmSrc;
  wire JAL, JALR, Branch;

  // Class flags
  wire LUI, AUIPC, ALUreg, ALUimm, Load, Store, SYSTEM;

  // Instantiate DUT
  decoder_glue dut (
      .instr(instr),
      .imm_out(imm),
      .reg_write(regWrite),
      .mem_read(MemRead),
      .mem_write(MemWrite),
      .alu_src(ALUSrc),
      .branch_sig(BranchSig),
      .jump(Jump),
      .alu_op(ALUOp),
      .imm_sel(ImmSrc),
      .wb_sel(wb_sel),
      .is_jal(JAL),
      .is_jalr(JALR),
      .is_branch(Branch),
      .is_lui(LUI),
      .is_auipc(AUIPC),
      .is_alu_reg(ALUreg),
      .is_alu_imm(ALUimm),
      .is_load(Load),
      .is_store(Store),
      .is_system(SYSTEM)
  );

  // ---- Opcodes ----
  localparam [6:0] OPC_RTYPE = 7'b0110011;
  localparam [6:0] OPC_ITYPE = 7'b0010011;
  localparam [6:0] OPC_LOAD = 7'b0000011;
  localparam [6:0] OPC_STORE = 7'b0100011;
  localparam [6:0] OPC_BRANCH = 7'b1100011;
  localparam [6:0] OPC_JAL = 7'b1101111;
  localparam [6:0] OPC_JALR = 7'b1100111;
  localparam [6:0] OPC_LUI = 7'b0110111;
  localparam [6:0] OPC_AUIPC = 7'b0010111;

  // ---- Proper 32-bit builders (no sign-extend into instr) ----
  function [31:0] mk_r;
    input [6:0] funct7;
    input [4:0] rs2, rs1;
    input [2:0] funct3;
    input [4:0] rd;
    begin
      mk_r = {funct7, rs2, rs1, funct3, rd, OPC_RTYPE};
    end
  endfunction

  function [31:0] mk_i;  // for I-ALU, LOAD, JALR (opcode selects kind)
    input [11:0] imm12;
    input [4:0] rs1;
    input [2:0] funct3;
    input [4:0] rd;
    input [6:0] opc;
    begin
      mk_i = {imm12, rs1, funct3, rd, opc};
    end
  endfunction

  function [31:0] mk_s;  // STORE
    input [11:0] imm12;
    input [4:0] rs2, rs1;
    input [2:0] funct3;
    begin
      mk_s = {imm12[11:5], rs2, rs1, funct3, imm12[4:0], OPC_STORE};
    end
  endfunction

  function [31:0] mk_b;  // BRANCH, imm13 must be even (LSB=0)
    input [12:0] imm13;
    input [4:0] rs2, rs1;
    input [2:0] funct3;
    begin
      mk_b = {imm13[12], imm13[10:5], rs2, rs1, funct3, imm13[4:1], imm13[11], OPC_BRANCH};
    end
  endfunction

  function [31:0] mk_u;  // LUI/AUIPC
    input [19:0] imm20;
    input [4:0] rd;
    input [6:0] opc;
    begin
      mk_u = {imm20, rd, opc};
    end
  endfunction

  function [31:0] mk_j;  // JAL, imm21 must be even (LSB=0)
    input [20:0] imm21;
    input [4:0] rd;
    begin
      mk_j = {imm21[20], imm21[10:1], imm21[11], imm21[19:12], rd, OPC_JAL};
    end
  endfunction

  // ---- Helpers ----
  task chk;
    input cond;
    input [8*64-1:0] msg;
    begin
      if (!cond) begin
        $display("FAIL: %s  instr=%h  t=%0t", msg, instr, $time);
        $fatal(1);
      end
    end
  endtask

  task settle;
    begin
      #1;
    end
  endtask

  // ---- Tests ----
  initial begin
    $display("Start decoder_glue tests...");

    $dumpfile("dump.vcd");
    $dumpvars(0, decoder_glue_tb);

    // R-type: add x5 = x1 + x2
    instr = mk_r(7'b0000000, 5'd2, 5'd1, 3'b000, 5'd5);
    settle();
    chk(rd == 5 && rs1 == 1 && rs2 == 2, "R-type slicer");
    chk(regWrite && !ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "R-type controls");
    chk(ALUOp == 2'b10, "R-type ALUOp");
    chk(wb_sel == 2'd0, "R-type wb_sel=ALU");
    chk(imm == 32'b0, "R-type imm 0");


    // I-type ALU: addi x6 = x1 + 0x7F  (special-case ALUOp=00)
    instr = mk_i(12'h07F, 5'd1, 3'b000, 5'd6, OPC_ITYPE);
    settle();
    chk(rd == 6 && rs1 == 1, "ADDI slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "ADDI controls");
    chk(ALUOp == 2'b00, "ADDI ALUOp=00");
    chk(wb_sel == 2'd0, "ADDI wb_sel=ALU");
    chk(imm == 32'h0000007F, "ADDI imm");

    // ---- More I-type ALU ops (ALUOp=10) ----

    // SLTI x6, x1, -1
    instr = mk_i(12'hFFF, 5'd1, 3'b010, 5'd6, OPC_ITYPE);
    settle();
    chk(rd == 6 && rs1 == 1, "SLTI slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "SLTI controls");
    chk(ALUOp == 2'b10, "SLTI ALUOp=10");
    chk(wb_sel == 2'd0, "SLTI wb_sel=ALU");
    chk(imm == 32'hFFFFF_FFF, "SLTI imm (sign-extended -1)");

    // SLTIU x7, x1, 1
    instr = mk_i(12'h001, 5'd1, 3'b011, 5'd7, OPC_ITYPE);
    settle();
    chk(rd == 7 && rs1 == 1, "SLTIU slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "SLTIU controls");
    chk(ALUOp == 2'b10, "SLTIU ALUOp=10");
    chk(wb_sel == 2'd0, "SLTIU wb_sel=ALU");
    chk(imm == 32'h00000001, "SLTIU imm");

    // XORI x8, x1, 0x00F
    instr = mk_i(12'h00F, 5'd1, 3'b100, 5'd8, OPC_ITYPE);
    settle();
    chk(rd == 8 && rs1 == 1, "XORI slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "XORI controls");
    chk(ALUOp == 2'b10, "XORI ALUOp=10");
    chk(wb_sel == 2'd0, "XORI wb_sel=ALU");
    chk(imm == 32'h0000000F, "XORI imm");

    // ORI x9, x1, 0x0F0
    instr = mk_i(12'h0F0, 5'd1, 3'b110, 5'd9, OPC_ITYPE);
    settle();
    chk(rd == 9 && rs1 == 1, "ORI slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "ORI controls");
    chk(ALUOp == 2'b10, "ORI ALUOp=10");
    chk(wb_sel == 2'd0, "ORI wb_sel=ALU");
    chk(imm == 32'h000000F0, "ORI imm");

    // ANDI x10, x1, 0x00F
    instr = mk_i(12'h00F, 5'd1, 3'b111, 5'd10, OPC_ITYPE);
    settle();
    chk(rd == 10 && rs1 == 1, "ANDI slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "ANDI controls");
    chk(ALUOp == 2'b10, "ANDI ALUOp=10");
    chk(wb_sel == 2'd0, "ANDI wb_sel=ALU");
    chk(imm == 32'h0000000F, "ANDI imm");

    // SLLI x11, x1, 4   (imm[11:5]=0000000, shamt=4)
    instr = mk_i({7'b0000000, 5'd4}, 5'd1, 3'b001, 5'd11, OPC_ITYPE);
    settle();
    chk(rd == 11 && rs1 == 1, "SLLI slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "SLLI controls");
    chk(ALUOp == 2'b10, "SLLI ALUOp=10");
    chk(wb_sel == 2'd0, "SLLI wb_sel=ALU");
    chk(imm == 32'h00000004, "SLLI imm (shamt)");

    // SRLI x12, x1, 5   (imm[11:5]=0000000, shamt=5)
    instr = mk_i({7'b0000000, 5'd5}, 5'd1, 3'b101, 5'd12, OPC_ITYPE);
    settle();
    chk(rd == 12 && rs1 == 1, "SRLI slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "SRLI controls");
    chk(ALUOp == 2'b10, "SRLI ALUOp=10");
    chk(wb_sel == 2'd0, "SRLI wb_sel=ALU");
    chk(imm == 32'h00000005, "SRLI imm (shamt)");

    // SRAI x13, x1, 5   (imm[11:5]=0100000, shamt=5)
    instr = mk_i({7'b0100000, 5'd5}, 5'd1, 3'b101, 5'd13, OPC_ITYPE);
    settle();
    chk(rd == 13 && rs1 == 1, "SRAI slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "SRAI controls");
    chk(ALUOp == 2'b10, "SRAI ALUOp=10");
    chk(wb_sel == 2'd0, "SRAI wb_sel=ALU");
    chk(imm == 32'h00000405, "SRAI imm (0100000<<5 | 5)");


    // LOAD: lw x7, 24(x3)
    instr = mk_i(12'd24, 5'd3, 3'b010, 5'd7, OPC_LOAD);
    settle();
    chk(rd == 7 && rs1 == 3, "LOAD slicer");
    chk(regWrite && ALUSrc && MemRead && !MemWrite && !BranchSig && !Jump, "LOAD controls");
    chk(ALUOp == 2'b00, "LOAD ALUOp");
    chk(wb_sel == 2'd1, "LOAD wb_sel=MEM");
    chk(imm == 32'd24, "LOAD imm");

    // STORE: sw x8, 28(x4)
    instr = mk_s(12'd28, 5'd8, 5'd4, 3'b010);
    settle();
    chk(rs1 == 4 && rs2 == 8, "STORE slicer");
    chk(!regWrite && ALUSrc && !MemRead && MemWrite && !BranchSig && !Jump, "STORE controls");
    chk(ALUOp == 2'b00, "STORE ALUOp");
    chk(wb_sel == 2'd0, "STORE wb_sel=ALU(ignore)");
    chk(imm == 32'd28, "STORE imm");

    // BRANCH: beq x1, x2, +16 (imm13 LSB must be 0)
    instr = mk_b(13'd16, 5'd2, 5'd1, 3'b000);
    settle();
    chk(rs1 == 1 && rs2 == 2, "BRANCH slicer");
    chk(!regWrite && !ALUSrc && !MemRead && !MemWrite && BranchSig && !Jump, "BRANCH controls");
    chk(ALUOp == 2'b01, "BRANCH ALUOp");
    chk(wb_sel == 2'd0, "BRANCH wb_sel");
    chk(imm == 32'd16, "BRANCH imm");

    // JAL: x1 <- PC+4, jump +32 (imm21 LSB must be 0)
    instr = mk_j(21'd32, 5'd1);
    settle();
    chk(rd == 1, "JAL slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && Jump, "JAL controls");
    chk(wb_sel == 2'd2 && JAL && !JALR, "JAL wb_sel=PC+4");
    chk(imm == 32'd32, "JAL imm");

    // JALR: x5 <- PC+4, rs1+20
    instr = mk_i(12'd20, 5'd9, 3'b000, 5'd5, OPC_JALR);
    settle();
    chk(rd == 5 && rs1 == 9, "JALR slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && Jump, "JALR controls");
    chk(wb_sel == 2'd2 && !JAL && JALR, "JALR wb_sel=PC+4");
    chk(imm == 32'd20, "JALR imm");

    // LUI
    instr = mk_u(20'h12345, 5'd10, OPC_LUI);
    settle();
    chk(rd == 10, "LUI slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "LUI controls");
    chk(ALUOp == 2'b00, "LUI ALUOp");
    chk(wb_sel == 2'd0, "LUI wb_sel");
    chk(imm == 32'h12345_000, "LUI imm");

    // AUIPC
    instr = mk_u(20'h01234, 5'd11, OPC_AUIPC);
    settle();
    chk(rd == 11, "AUIPC slicer");
    chk(regWrite && ALUSrc && !MemRead && !MemWrite && !BranchSig && !Jump, "AUIPC controls");
    chk(ALUOp == 2'b00, "AUIPC ALUOp");
    chk(wb_sel == 2'd0, "AUIPC wb_sel");
    chk(imm == 32'h01234_000, "AUIPC imm");

    $display("All decoder_glue tests passed.");
    $finish;
  end
endmodule
