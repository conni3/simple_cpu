`timescale 1ps / 1ps

module mux2_tb;
  localparam WIDTH = 32;

  reg [WIDTH-1:0] a;
  reg [WIDTH-1:0] b;
  reg sel;
  wire [WIDTH-1:0] y;

  mux2 #(
      .WIDTH(WIDTH)
  ) uut (
      .a  (a),
      .b  (b),
      .sel(sel),
      .y  (y)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, mux2_tb);

    a   = 32'hA5A5A5A5;
    b   = 32'h5A5A5A5A;

    sel = 0;
    #100;
    if (y !== a) $display("Test case 1 failed: Expected %h, got %h", a, y);

    sel = 1;
    #100;
    if (y !== b) $display("Test case 2 failed: Expected %h, got %h", b, y);

    $finish;
  end

endmodule
