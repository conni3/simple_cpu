`timescale 1ps / 1ps
`include "defines.vh"

module wb_mux (
    input wire [`DATA_WIDTH-1:0] alu_result,
    input wire [`DATA_WIDTH-1:0] rdata,         // data from data_mem (already extended)
    input wire [`DATA_WIDTH-1:0] pc_plus4,
    input wire [            1:0] wb_sel,        // WB_ALU/MEM/PC4
    input wire                   reg_write_in,  // from control
    input wire                   kill_wb,       // from trap/exception unit
    input wire [            4:0] rd_in,         // destination register index

    output reg  [`DATA_WIDTH-1:0] rd_wdata,
    output wire                   reg_write_out,  // gated write-enable
    output wire [            4:0] rd_out
);

  localparam reg [1:0] WB_ALU = 2'd0;
  localparam reg [1:0] WB_MEM = 2'd1;
  localparam reg [1:0] WB_PC4 = 2'd2;

  always @* begin
    case (wb_sel)
      WB_ALU:  rd_wdata = alu_result;
      WB_MEM:  rd_wdata = rdata;
      WB_PC4:  rd_wdata = pc_plus4;
      default: rd_wdata = {`DATA_WIDTH{1'b0}};
    endcase
  end

  // Block writes on kill, and avoid x0 writes here (regfile also ignores)
  assign reg_write_out = reg_write_in && !kill_wb && (rd_in != 5'd0);
  assign rd_out        = rd_in;

endmodule
