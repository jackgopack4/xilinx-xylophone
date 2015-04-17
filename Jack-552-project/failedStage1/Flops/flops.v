// DFF datapath module (for writes to memory) in-class exercise
// Authors: John Peterson, David Hartman
// 30 SEP 2014
// ECE552
module flops(DM_re_ID_EX_DM, DM_we_ID_EX_DM, RF_we_DM_WB, RF_dst_addr_DM_WB, instr, clk, rst_n);
  // IM block input 
  input [15:0] instr;

  // global clock and reset for DFFs
  input clk, rst_n;

  // Mem block outputs
  output DM_re_ID_EX_DM, DM_we_ID_EX_DM;

  // WB block outputs
  output RF_we_DM_WB;
  output [3:0] RF_dst_addr_DM_WB;

  // ID block wires
  wire [15:0] instr_IM_ID;
  wire DM_re, DM_we, RF_we;
  wire [3:0] RF_dst_addr;
  
  // EX block wires
  wire DM_re_ID_EX, DM_we_ID_EX;
  wire RF_we_ID_EX;
  wire [3:0] RF_dst_addr_ID_EX;

  // MEM block
  wire RF_we_EX_DM;
  wire [3:0] RF_dst_addr_EX_DM;

  // ID block
  flop16b ID_flop(instr_IM_ID, instr, clk, rst_n);
  block_ID ID_block(DM_re, DM_we, RF_we, RF_dst_addr, instr_IM_ID);

  // EX block
  flop2b ex_2({DM_re_ID_EX,DM_we_ID_EX}, {DM_re,DM_we}, clk, rst_n);
  flop1b ex_1(RF_we_ID_EX, RF_we, clk, rst_n);
  flop4b ex_4(RF_dst_addr_ID_EX, RF_dst_addr, clk, rst_n);

  // MEM block
  flop2b mem_2({DM_re_ID_EX_DM,DM_we_ID_EX_DM}, {DM_re_ID_EX,DM_we_ID_EX}, clk, rst_n);
  flop1b mem_1(RF_we_EX_DM, RF_we_ID_EX, clk, rst_n);
  flop4b mem_4(RF_dst_addr_EX_DM, RF_dst_addr_ID_EX, clk, rst_n);

  // WB block
  flop1b wb_1(RF_we_DM_WB, RF_we_EX_DM, clk, rst_n);
  flop4b wb_4(RF_dst_addr_DM_WB, RF_dst_addr_EX_DM, clk, rst_n);

endmodule
