// Blank module to implement ID block in future
// Authors: John Peterson, David Hartman
// 30 SEP 2014
// ECE552
module block_ID(DM_re, DM_we, RF_we, RF_dst_addr, instr_IM_ID);

  input [15:0] instr_IM_ID;
  output DM_re, DM_we, RF_we;
  output [3:0] RF_dst_addr;

endmodule
