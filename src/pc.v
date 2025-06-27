// pc.v
module pc (
    input  wire        clk,        // Clock signal
    input  wire        reset,      // Asynchronous reset, active high
    input  wire [31:0] next_pc,    // Next PC value (from adder/MUX)
    output reg  [31:0] current_pc  // Holds the current PC value
);

  // On the rising edge of clk or an asserted reset...
  always @(posedge clk or posedge reset) begin
    if (reset) 
      current_pc <= 32'b0;        // Initialize PC to 0 after reset
    else
      current_pc <= next_pc;      // Otherwise, load next_pc
  end

endmodule
