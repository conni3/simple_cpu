module data_mem_tb;
  reg clk;
  reg we;
  reg [10:0] addr;
  reg [31:0] write_data;
  wire [31:0] read_data;


  data_mem uut (
      .clk(clk),
      .we(we),
      .addr(addr),
      .write_data(write_data),
      .read_data(read_data)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, data_mem_tb);

    clk = 0;
    we = 0;
    addr = 11'h000;
    write_data = 32'h00000000;


    we = 1;
    addr = 11'h001;  // Write to address 1
    write_data = 32'hDEADBEEF;
    #10;


    we   = 0;
    addr = 11'h001;
    #10;

    if (read_data !== 32'hDEADBEEF) begin
      $display("Test failed: Expected 32'hDEADBEEF, got %h", read_data);
    end else begin
      $display("Test passed: Read data is %h", read_data);
    end

    $finish;
  end


endmodule
