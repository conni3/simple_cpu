`timescale 1ns / 1ps

// Parameterized instruction memory (ROM) module
`define MEM_FILE "instr_mem.mem"
module instr_mem #(
    parameter DATA_WIDTH = 32,     // instruction width
    parameter ADDR_WIDTH = 11      // depth = 2^ADDR_WIDTH instructions
)(
    input  wire [ADDR_WIDTH-1:0] addr,   // instruction address (word-aligned)
    output reg  [DATA_WIDTH-1:0] instr   // fetched instruction
);

    // ROM array declaration
    reg [DATA_WIDTH-1:0] mem [(1<<ADDR_WIDTH)-1:0];

    // Initialize ROM from memory file (binary values)
    initial begin
        $readmemb(`MEM_FILE, mem);
    end

    // Asynchronous read: instruction appears immediately
    always @(*) begin
        instr = mem[addr];
    end

endmodule
