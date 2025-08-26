`timescale 1ps / 1ps
`include "defines.vh"

module wb_mux_tb;
  localparam [1:0] WB_ALU = 2'd0, WB_MEM = 2'd1, WB_PC4 = 2'd2;

  reg [`DATA_WIDTH-1:0] alu_result, rdata, pc_plus4;
  reg [1:0] wb_sel;
  reg reg_write_in, kill_wb;
  reg  [            4:0] rd_in;

  wire [`DATA_WIDTH-1:0] rd_wdata;
  wire                   reg_write_out;
  wire [            4:0] rd_out;

  wb_mux dut (
      .alu_result(alu_result),
      .rdata(rdata),
      .pc_plus4(pc_plus4),
      .wb_sel(wb_sel),
      .reg_write_in(reg_write_in),
      .kill_wb(kill_wb),
      .rd_in(rd_in),
      .rd_wdata(rd_wdata),
      .reg_write_out(reg_write_out),
      .rd_out(rd_out)
  );

  integer fails;

  initial begin
    fails        = 0;
    alu_result   = 32'hA1A1_A1A1;
    rdata        = 32'hB2B2_B2B2;
    pc_plus4     = 32'hC3C3_C3C3;
    reg_write_in = 1'b1;
    kill_wb      = 1'b0;
    rd_in        = 5'd10;

    $dumpfile("dump.vcd");
    $dumpvars(0, wb_mux_tb);

    wb_sel = WB_ALU;
    #1;
    check("ALU path data", rd_wdata === alu_result);
    check("ALU path reg_write", reg_write_out === 1'b1);
    check("ALU rd passthrough", rd_out === rd_in);

    wb_sel = WB_MEM;
    #1;
    check("MEM path data", rd_wdata === rdata);

    wb_sel = WB_PC4;
    #1;
    check("PC+4 path data", rd_wdata === pc_plus4);

    kill_wb = 1'b1;
    #1;
    check("Kill gating disables write", reg_write_out === 1'b0);
    kill_wb = 1'b0;
    #1;

    rd_in  = 5'd0;
    wb_sel = WB_ALU;
    #1;
    check("x0 write blocked", reg_write_out === 1'b0);
    rd_in = 5'd31;
    #1;
    check("x31 write allowed", reg_write_out === 1'b1);

    if (fails == 0) $display("PASS: all wb_mux tests");
    else $display("FAIL: %0d test(s)", fails);
    $finish;
  end

  task check;
    input [8*64-1:0] name;
    input cond;
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
