// Program Counter module
// Takes input and provides output
// ECE552 EX09
// Authors: John Peterson, David Hartman
// 2 OCT 2014
module ProgramCounter(pc, pc_ID_EX, pc_EX_DM, dst_ID_EX, flow_change_ID_EX, stall, rst_n, clk);

input [15:0] dst_ID_EX;
input flow_change_ID_EX, stall, rst_n, clk;
output [15:0] pc, pc_ID_EX, pc_EX_DM;

wire [15:0] pc_inc, pc_next, pc_D, pc_IM, pc_IM_ID;

//program counter
assign pc_next = flow_change_ID_EX ? dst_ID_EX : pc_inc;
assign pc_D = stall ? pc : pc_next;

flop16b pcFlop(.d(pc_D), .q(pc), .clk(clk), .rst_n(rst_n));

assign pc_inc = pc + 1;

//pipeline flops
assign pc_IM = stall ? pc_IM_ID : pc_inc;

flop16b IM_ID(.d(pc_IM), .q(pc_IM_ID), .clk(clk), .rst_n(rst_n));
flop16b ID_EX(.d(pc_IM_ID), .q(pc_ID_EX), .clk(clk), .rst_n(rst_n));
flop16b EX_DM(.d(pc_ID_EX), .q(pc_EX_DM), .clk(clk), .rst_n(rst_n));

endmodule
