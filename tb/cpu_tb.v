
`timescale 1ns / 1ps

module cpu_tb;
  localparam integer MAX_CYCLES = 20;
  localparam integer ADDR_WIDTH = 11;
  localparam IMEM_FILE = "./tests/prog.mem";
  localparam [31:0] END_SENTINEL = 32'h0000_006F;

  reg clk = 1'b0;
  reg reset = 1'b1;
  integer k;
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

  task run_cycles(input integer n);
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
  integer instr_count = 0;
  reg reg_ok, mem_ok, finished;
  initial begin
    #1;
    $display("[SANITY] imem[0]=%h dmem[16]=%h", dut.u_datapath.u_imem.mem[0],
             dut.u_datapath.u_dmem.mem[16]);
  end



  initial begin
    reg_ok   = 1'b0;
    mem_ok   = 1'b0;
    finished = 1'b0;

    $dumpfile("dump.vcd");
    $dumpvars(0, cpu_tb);

    reset = 1'b1;
    run_cycles(5);
    reset = 1'b0;

    begin : end_test
      for (cycles = 0; cycles < MAX_CYCLES; cycles = cycles + 1) begin
        @(posedge clk);
        if (!reset) instr_count = instr_count + 1;

        if (!reg_ok && (dut.u_datapath.u_rf.regs[6] === 32'h0000_0010)) begin
          $display("[PASS-1] x6 == 0x00000010 at cycle %0d", cycles);
          reg_ok = 1'b1;
        end

        if (!mem_ok && (dut.u_datapath.u_dmem.mem[16] === 32'hDEAD_BEEF)) begin
          $display("[PASS-2] DMEM[0x40] == 0xDEADBEEF at cycle %0d", cycles);
          mem_ok = 1'b1;
        end

        if (dut.u_datapath.instr === 32'h0000_006F) begin
          $display("[INFO] Reached END_SENTINEL (jal x0,0) at PC=%h, cycle %0d", debug_pc, cycles);
          real cpi;
          cpi = cycles;
          cpi = cpi / instr_count;
          $display("[PERF] CPI=%0f", cpi);
          finished = 1'b1;
          disable end_test;
        end
      end
      $display("[TIMEOUT] No END_SENTINEL by %0d cycles.", MAX_CYCLES);
    end


    if (reg_ok && mem_ok) $display("[PASS] All checks satisfied.");
    else begin
      if (!reg_ok) $display("[FAIL] x6 never reached 0x00000010.");
      if (!mem_ok) $display("[FAIL] DMEM[0x40] never became 0xDEADBEEF.");
    end

    for (k = 0; k < 17; k = k + 1) $display("DMEM[%0d] = %h", k, dut.u_datapath.u_dmem.mem[k]);
    $finish;

  end

endmodule
