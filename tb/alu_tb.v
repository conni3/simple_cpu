`timescale 1ns/1ps

module alu_tb;
    // Testbench signals
    reg  [31:0] operand_a;
    reg  [31:0] operand_b;
    reg  [3:0]  alu_control;
    wire [31:0] alu_result;
    wire        zero;

    // Instantiate the DUT
    alu uut (
        .operand_a   (operand_a),
        .operand_b   (operand_b),
        .alu_control (alu_control),
        .alu_result  (alu_result),
        .zero        (zero)
    );

    // Task to apply a test vector
    task do_test;
        input [31:0] a;
        input [31:0] b;
        input [3:0]  ctrl;
        input [31:0] expected;
        begin
            operand_a   = a;
            operand_b   = b;
            alu_control = ctrl;
            #10;
            if (alu_result !== expected) begin
                $display("ERROR: ctrl=%b, a=%d, b=%d => got %d, expected %d", ctrl, a, b, alu_result, expected);
            end else begin
                $display("PASS:  ctrl=%b, a=%d, b=%d => %d", ctrl, a, b, alu_result);
            end
        end
    endtask

    initial begin
        $display("Starting ALU testbench...");

        // ADD
        do_test( 32'd15, 32'd10, 4'b0000, 32'd25);
        // SUB
        do_test( 32'd15, 32'd10, 4'b0001, 32'd5);
        // SLL (shift left logical)
        do_test( 32'h0000_0001, 32'd4,  4'b0010, 32'h0000_0010);
        // SLT (signed)
        do_test( -32'd1,    32'd1,  4'b0011, 32'd1);
        // SLTU (unsigned)
        do_test( 32'd1,     32'd2,  4'b0100, 32'd1);
        // XOR
        do_test( 32'hF0F0_F0F0, 32'h0F0F_0F0F, 4'b0101, 32'hFFFF_FFFF);
        // SRL (shift right logical)
        do_test( 32'h8000_0000, 32'd31, 4'b0110, 32'h0000_0001);
        // SRA (shift right arithmetic)
        do_test( 32'h8000_0000, 32'd31, 4'b0111, 32'hFFFF_FFFF);
        // OR
        do_test( 32'h1234_5678, 32'h8765_4321, 4'b1000, 32'h9775_5779);
        // AND
        do_test( 32'hFFFF_0000, 32'h00FF_FF00, 4'b1001, 32'h00FF_0000);

        // Zero flag check
        operand_a   = 32'd5;
        operand_b   = 32'd5;
        alu_control = 4'b0001; // SUB
        #10;
        if (zero) $display("PASS: Zero flag asserted");
        else      $display("ERROR: Zero flag not asserted");

        $display("ALU testbench complete.");
        $finish;
    end
endmodule
