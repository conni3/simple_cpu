`timescale 1ns / 1ps

// Parameterized data memory module
// Synchronous write, synchronous read
module data_mem #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 11  // depth = 2^ADDR_WIDTH words
)(
    input  wire                  clk,         // Clock
    input  wire                  we,          // Write enable
    input  wire [ADDR_WIDTH-1:0] addr,        // Address (word-aligned)
    input  wire [DATA_WIDTH-1:0] write_data,  // Data to write
    output reg  [DATA_WIDTH-1:0] read_data    // Data output
);

    // Memory array declaration
    reg [DATA_WIDTH-1:0] mem [(1<<ADDR_WIDTH)-1:0];

    // Write and read operations
    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= write_data;
        end
        read_data <= mem[addr];
    end

endmodule
