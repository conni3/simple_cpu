`timescale 1ps / 1ps
`include "defines.vh"

module wb_mux_tb;
  // Keep these in sync with wb_mux
  localparam [1:0] WB_ALU = 2'd0;
  localparam [1:0] WB_MEM = 2'd1;
  localparam [1:0] WB_PC4 = 2'd2;
  localparam [1:0] WB_CSR = 2'd3;

  // Stimuli
  reg  [DATA_WIDTH-1:0] alu_result;
  reg  [DATA_WIDTH-1:0] load_rdata;
  reg  [DATA_WIDTH-1:0] pc_plus4;
  reg  [DATA_WIDTH-1:0] csr_rdata;
  reg  [           1:0] wb_sel;
  reg                   regwrite_in;
  reg                   kill_wb;
  reg  [           4:0] rd_in;

  // DUT (HAS_CSR = 1)
  wire [DATA_WIDTH-1:0] rd_wdata;
  wire                  regwrite_out;
  wire [           4:0] rd_out;

  wb_mux #(
      .HAS_CSR(1)
  ) dut (
      .alu_result  (alu_result),
      .load_rdata  (load_rdata),
      .pc_plus4    (pc_plus4),
      .csr_rdata   (csr_rdata),
      .wb_sel      (wb_sel),
      .regwrite_in (regwrite_in),
      .kill_wb     (kill_wb),
      .rd_in       (rd_in),
      .rd_wdata    (rd_wdata),
      .regwrite_out(regwrite_out),
      .rd_out      (rd_out)
  );

  // Second DUT to check CSR-disabled behavior
  wire [DATA_WIDTH-1:0] rd_wdata_nocsr;
  wire                  regwrite_out_nocsr;
  wire [           4:0] rd_out_nocsr;

  wb_mux #(
      .HAS_CSR(0)
  ) dut_nocsr (
      .alu_result  (alu_result),
      .load_rdata  (load_rdata),
      .pc_plus4    (pc_plus4),
      .csr_rdata   (csr_rdata),
      .wb_sel      (wb_sel),
      .regwrite_in (regwrite_in),
      .kill_wb     (kill_wb),
      .rd_in       (rd_in),
      .rd_wdata    (rd_wdata_nocsr),
      .regwrite_out(regwrite_out_nocsr),
      .rd_out      (rd_out_nocsr)
  );

  integer fails;

  initial begin
    fails       = 0;

    // Default stimuli
    alu_result  = 32'hA1A1_A1A1;
    load_rdata  = 32'hB2B2_B2B2;
    pc_plus4    = 32'hC3C3_C3C3;
    csr_rdata   = 32'hD4D4_D4D4;
    regwrite_in = 1'b1;
    kill_wb     = 1'b0;
    rd_in       = 5'd10;

    // 1) ALU select
    wb_sel      = WB_ALU;
    #1;
    check("ALU path data", rd_wdata === alu_result);
    check("ALU path regwrite", regwrite_out === 1'b1);
    check("ALU rd passthrough", rd_out === rd_in);

    // 2) MEM select
    wb_sel = WB_MEM;
    #1;
    check("MEM path data", rd_wdata === load_rdata);

    // 3) PC+4 select
    wb_sel = WB_PC4;
    #1;
    check("PC+4 path data", rd_wdata === pc_plus4);


    // 5) Kill gating
    kill_wb = 1'b1;
    #1;
    check("Kill gating disables write", regwrite_out === 1'b0);
    kill_wb = 1'b0;
    #1;

    // 6) x0 write blocked
    rd_in  = 5'd0;
    wb_sel = WB_ALU;
    #1;
    check("x0 write blocked", regwrite_out === 1'b0);
    rd_in = 5'd31;
    #1;
    check("x31 write allowed", regwrite_out === 1'b1);

    // 7) CSR path when HAS_CSR=0 should drive zeros
    wb_sel = WB_CSR;
    #1;
    check("CSR path zeros when HAS_CSR=0", rd_wdata_nocsr === {DATA_WIDTH{1'b0}});
    check("rd passthrough unaffected (nocsr)", rd_out_nocsr === rd_in);

    if (fails == 0) $display("PASS: all wb_mux tests");
    else $display("FAIL: %0d test(s)", fails);
    $finish;
  end

  task check(input [8*64-1:0] name, input bit cond);
    begin
      if (!cond) begin
        $display("FAIL: %0s", name);
        fails = fails + 1;
      end else begin
        $display("PASS: %0s", name);
      end
    end
  endtask

endmodule
