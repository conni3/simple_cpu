`timescale 1ns / 1ps

module cpu_tb;
  localparam integer MAX_CYCLES = 20;
  localparam integer ADDR_WIDTH = 11;
  localparam IMEM_FILE = "./tests/r_alu.mem";
  localparam [31:0] END_SENTINEL = 32'h0000_006F;
  parameter [31:0] STATUS_ADDR = 32'h0000_0000;
  localparam [31:0] STATUS_PASS = 32'hC0DE_CAFE;

  reg clk = 1'b0;
  reg reset = 1'b1;
  integer k;
  real cpi;  
  wire [31:0] debug_pc;

  cpu #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .IMEM_FILE (IMEM_FILE)
  ) dut (
      .clk(clk),
      .reset(reset),
      .debug_pc(debug_pc)
  );

  always #5 clk = ~clk;

  task run_cycles;
    input integer n;
    integer i;
    begin
      for (i = 0; i < n; i = i + 1) @(posedge clk);
    end
  endtask

  always @(posedge clk)
    if (!reset) begin
      $display("t=%0t PC=%h INSTR=%h", $time, debug_pc, dut.u_datapath.instr);
    end

  always @(posedge clk) begin
    if (!reset && dut.u_datapath.mem_write) begin
      $display("STORE @%0t: addr=%h wdata=%h", $time, dut.u_datapath.dmem_addr,
               dut.u_datapath.rs2_data);
    end
  end

  always @(posedge clk) begin
    if (!reset && dut.u_datapath.mem_write && (dut.u_datapath.dmem_addr[1:0] != 2'b00)) begin
      $display("WARN: misaligned store addr=%h", dut.u_datapath.dmem_addr);
    end
  end

  integer cycles;
  integer instr_count;
  reg status_ok, finished;

  initial begin
    #1;
    $display("[SANITY] imem[0]=%h dmem[%0d]=%h", dut.u_datapath.u_imem.mem[0],
             STATUS_ADDR>>2, dut.u_datapath.u_dmem.mem[STATUS_ADDR>>2]);
  end

  initial begin
    status_ok   = 1'b0;
    finished    = 1'b0;
    instr_count = 0;

    $dumpfile("dump.vcd");
    $dumpvars(0, cpu_tb);

    reset = 1'b1;
    run_cycles(5);
    reset = 1'b0;

    begin : end_test
      for (cycles = 0; cycles < MAX_CYCLES; cycles = cycles + 1) begin
        @(posedge clk);
        if (!reset) instr_count = instr_count + 1;

        if (!status_ok && (dut.u_datapath.u_dmem.mem[STATUS_ADDR>>2] === STATUS_PASS)) begin
          $display("[PASS] STATUS_ADDR contains STATUS_PASS at cycle %0d", cycles);
          status_ok = 1'b1;
        end

        if (dut.u_datapath.instr === END_SENTINEL) begin
          $display("[INFO] Reached END_SENTINEL (jal x0,0) at PC=%h, cycle %0d", debug_pc, cycles);
          if (instr_count != 0) begin
            cpi = (cycles * 1.0) / instr_count;
            $display("[PERF] CPI=%0f", cpi);
          end else begin
            $display("[PERF] CPI=undefined (instr_count=0)");
          end
          finished = 1'b1;
          disable end_test;
        end
      end
      $display("[TIMEOUT] No END_SENTINEL by %0d cycles.", MAX_CYCLES);
    end

      if (status_ok) $display("[PASS] Program signaled PASS.");
      else $display("[FAIL] STATUS_ADDR never had STATUS_PASS.");

    for (k = 0; k < 17; k = k + 1)
      $display("DMEM[%0d] = %h", k, dut.u_datapath.u_dmem.mem[k]);

    $finish;
  end

endmodule
