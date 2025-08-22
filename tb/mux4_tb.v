`timescale 1ps / 1ps


module mux4_tb;


  reg  [31:0] a;
  reg  [31:0] b;
  reg  [31:0] c;
  reg  [31:0] d;
  reg  [ 1:0] sel;


  wire [31:0] y;


  mux4 uut (
      .a  (a),
      .b  (b),
      .c  (c),
      .d  (d),
      .sel(sel),
      .y  (y)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, mux4_tb);

    a   = 32'h00000001;
    b   = 32'h00000002;
    c   = 32'h00000003;
    d   = 32'h00000004;
    sel = 2'b00;

    #100;

    sel = 2'b01;
    #100;

    if (y !== 32'h00000001) begin
      $display("Test failed for sel = 2'b00: y = %h", y);
    end else begin
      $display("Test passed for sel = 2'b00: y = %h", y);
    end

    sel = 2'b10;
    #100;

    if (y !== 32'h00000002) begin
      $display("Test failed for sel = 2'b01: y = %h", y);
    end else begin
      $display("Test passed for sel = 2'b01: y = %h", y);
    end

    sel = 2'b11;
    #100;

    if (y !== 32'h00000003) begin
      $display("Test failed for sel = 2'b10: y = %h", y);
    end else begin
      $display("Test passed for sel = 2'b10: y = %h", y);
    end


    sel = 2'b00;
    #100;


    if (y !== 32'h00000004) begin
      $display("Test failed for sel = 2'b11: y = %h", y);
    end else begin
      $display("Test passed for sel = 2'b11: y = %h", y);
    end

    $finish;
  end

endmodule
