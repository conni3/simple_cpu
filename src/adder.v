`timescale 1ns / 1ps

// 32-bit parameterized adder module
module adder #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] result
);

    // Simple combinational addition
    assign result = a + b;

endmodule
