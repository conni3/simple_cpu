`timescale 1ps / 1ps
`include "include/defines.vh"

// wb_sel encodings
localparam WB_ALU = 2'd0;
localparam WB_MEM = 2'd1;
localparam WB_PC4 = 2'd2;

module wb_mux (
    input  wire [DATA_WIDTH-1:0] alu_result,
    input  wire [DATA_WIDTH-1:0] load_rdata,
    input  wire [DATA_WIDTH-1:0] pc_plus4,
    input  wire [           1:0] wb_sel,        // WB_ALU/MEM/PC4/CSR
    input  wire                  regwrite_in,   // from controller
    input  wire                  kill_wb,       // from trap/exception unit
    input  wire [           4:0] rd_in,         // destination reg index
    output reg  [DATA_WIDTH-1:0] rd_wdata,
    output wire                  regwrite_out,  // gated write-enable
    output wire [           4:0] rd_out
);

  always @* begin
    unique case (wb_sel)
      WB_ALU:  rd_wdata = alu_result;
      WB_MEM:  rd_wdata = load_rdata;  // assume already properly extended
      WB_PC4:  rd_wdata = pc_plus4;
      default: rd_wdata = {DATA_WIDTH{1'b0}};
    endcase
  end

  // Gate writes on traps; optionally also block x0 writes here (regfile usually ignores)
  assign regwrite_out = regwrite_in && !kill_wb && (rd_in != 5'd0);
  assign rd_out       = rd_in;

endmodule
