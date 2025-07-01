`timescale 1ns / 1ps

// 2-to-1 parameterized multiplexer module
module mux2 #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] a,    // Input A
    input  wire [WIDTH-1:0] b,    // Input B
    input  wire           sel,   // Select signal
    output wire [WIDTH-1:0] y     // Output
);

    // Output Y is A when sel=0, B when sel=1
    assign y = sel ? b : a;

endmodule
