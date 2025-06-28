`timescale 1ns/1ps

module regfile_tb;
    // Signals
    reg         clk;
    reg         reset;
    reg         regwrite;
    reg  [4:0]  read_reg1, read_reg2, write_reg;
    reg  [31:0] write_data;
    wire [31:0] read_data1, read_data2;

    // Golden model of the register file contents
    reg [31:0] expected [31:0];

    // Instantiate DUT
    reg_file uut (
        .clk        (clk),
        .reset      (reset),
        .regwrite   (regwrite),
        .read_reg1  (read_reg1),
        .read_reg2  (read_reg2),
        .write_reg  (write_reg),
        .write_data (write_data),
        .read_data1 (read_data1),
        .read_data2 (read_data2)
    );

    // Clock generator (10 ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // Write task: drives write port on next rising edge, updates golden model
    task writeReg(input [4:0] addr, input [31:0] data);
    begin
        // prepare for write
        @(negedge clk);
        regwrite   = 1;
        write_reg  = addr;
        write_data = data;
        // capture on posedge
        @(posedge clk);
        if (addr != 0)
            expected[addr] = data;
    end
    endtask

    // Read & check task: compares DUT’s outputs to golden model
    task readAndCheck(input [4:0] addr1,
                      input [4:0] addr2);
    reg [31:0] exp1, exp2;
    begin
        exp1 = expected[addr1];
        exp2 = expected[addr2];
        read_reg1 = addr1;
        read_reg2 = addr2;
        #1; // allow combinational read to settle
        if (read_data1 !== exp1)
          $display("ERROR: time=%0t READ1[%0d]=0x%08h (exp=0x%08h)",
                   $time, addr1, read_data1, exp1);
        else
          $display("PASS : time=%0t READ1[%0d]=0x%08h",
                   $time, addr1, read_data1);
        if (read_data2 !== exp2)
          $display("ERROR: time=%0t READ2[%0d]=0x%08h (exp=0x%08h)",
                   $time, addr2, read_data2, exp2);
        else
          $display("PASS : time=%0t READ2[%0d]=0x%08h",
                   $time, addr2, read_data2);
    end
    endtask

    integer i;
    reg [4:0] next_reg;

    initial begin
        // dump waveform
        $dumpfile("dump.vcd");
        $dumpvars(0, regfile_tb);

        // Initialize DUT signals
        reset      = 1;
        regwrite   = 0;
        read_reg1  = 0;
        read_reg2  = 0;
        write_reg  = 0;
        write_data = 0;
        // Initialize golden model to zeros
        for (i = 0; i < 32; i = i + 1)
            expected[i] = 32'd0;

        $display("\n===== Extended Register File Testbench =====\n");

        // 1) SYNCHRONOUS RESET TEST
        #12 reset = 0;  // hold reset through one rising edge
        #1;            // wait for async-read settle
        $display("-- After reset (all regs should be 0) --");
        for (i = 0; i < 32; i = i + 2)
            readAndCheck(i, i+1);

        // 2) ZERO-REGISTER PROTECTION
        $display("\n-- Attempt write to x0 (should remain 0) --");
        writeReg(5'd0, 32'hDEADBEEF);
        readAndCheck(5'd0, 5'd1);

        // 3) INDIVIDUAL WRITES 1–31
        $display("\n-- Write/read pattern to x1..x31 --");
        for (i = 1; i < 32; i = i + 1) begin
            writeReg(i, i * 32'h11111111);
            readAndCheck(i, 5'd0);
        end

        // 4) BACK‐TO‐BACK WRITES
        $display("\n-- Back‐to‐back writes to x5 and x10 --");
        writeReg(5'd5,  32'hAAAA0000);
        writeReg(5'd10, 32'h5555FFFF);
        readAndCheck(5'd5, 5'd10);

        // 5) RANDOMIZED STRESS TEST
        $display("\n-- Randomized writes & reads --");
        for (i = 0; i < 20; i = i + 1) begin
            next_reg = $urandom_range(0,31);
            writeReg(next_reg,
                     (next_reg==0) ? 32'h0 : $urandom);
            readAndCheck(next_reg, $urandom_range(0,31));
        end

        // 6) FINAL RESET
        $display("\n-- Assert reset again (all should clear) --");
        #5 reset = 1;
        @(posedge clk);
        reset = 0;
        #1;
        for (i = 0; i < 8; i = i + 1)
            readAndCheck(i, i+8);

        $display("\n===== Test Complete =====\n");
        #10 $finish;
    end
endmodule
