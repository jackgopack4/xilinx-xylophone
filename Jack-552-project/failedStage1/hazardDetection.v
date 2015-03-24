module hazardDetection(WB_dst_addr_ID_EX, DM_MemRead_ID_EX, instr_IF_ID, stall);
input [3:0] WB_dst_addr_ID_EX;	// MemRead
input DM_MemRead_ID_EX;		// ID/EX Rt
input [15:0] instr_IF_ID;
output reg stall;

always @(WB_dst_addr_ID_EX, DM_MemRead_ID_EX, instr_IF_ID) begin
  //
  if (DM_MemRead_ID_EX) begin
    // WB_dst_addr_ID_EX = rs ?
    if((WB_dst_addr_ID_EX == instr_IF_ID[7:4] && instr_IF_ID[15] == 1'b0)  //Rs -> ALU ops 
    || (WB_dst_addr_ID_EX == instr_IF_ID[7:4] && instr_IF_ID[15:13] == 3'b100)  //Rs -> lw/sw ops 
    || (WB_dst_addr_ID_EX == instr_IF_ID[11:8] && instr_IF_ID[15:12] == 4'b1010) //Rs -> LHB op
    || (WB_dst_addr_ID_EX == instr_IF_ID[7:4] && instr_IF_ID[15:12] == 4'b1110)) begin  //Rs -> JR op
      stall = 1'b1; 
    end 
    // WB_dst_addr_ID_EX = rs ?
    else if((WB_dst_addr_ID_EX == instr_IF_ID[3:0] && instr_IF_ID[15:14] == 2'b00)  //Rt -> ALU ops 
         || (WB_dst_addr_ID_EX == instr_IF_ID[11:8] && instr_IF_ID[15:12] == 4'b1001)) begin  //Rt -> SW
      stall = 1'b1;   
    end
  end
  //Not a lw instruction no stall
  else begin
    stall = 1'b0;
  end
end

endmodule 
