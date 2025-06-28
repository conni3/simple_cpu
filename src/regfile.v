// regfile.v
// 32×32 register file with two read ports and one write port

module reg_file (
    input  wire        clk,         // clock
    input  wire        reset,       // active‐high synchronous reset
    input  wire        regwrite,    // write enable
    input  wire [4:0]  read_reg1,   // address of source register 1
    input  wire [4:0]  read_reg2,   // address of source register 2
    input  wire [4:0]  write_reg,   // address of destination register
    input  wire [31:0] write_data,  // data to write
    output wire [31:0] read_data1,  // data from source register 1
    output wire [31:0] read_data2   // data from source register 2
);

    // Register storage
    reg [31:0] regs [31:0];
    integer i;

    // Write logic (and optional reset)
    always @(posedge clk) begin
        if (reset) begin
            // clear all registers on reset
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end else if (regwrite && (write_reg != 5'd0)) begin
            // write to regs[write_reg]; skip register 0
            regs[write_reg] <= write_data;
        end
    end

    // Asynchronous read ports (register 0 always reads 0)
    assign read_data1 = (read_reg1 != 5'd0) ? regs[read_reg1] : 32'b0;
    assign read_data2 = (read_reg2 != 5'd0) ? regs[read_reg2] : 32'b0;

endmodule
