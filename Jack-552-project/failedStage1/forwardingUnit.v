module forwardingUnit(EX_Rs_Addr_ID_EX, EX_Rt_Addr_ID_EX, WB_dst_addr_EX_DM, WB_dst_addr_DM_WB,
					WB_RegWrite_EX_DM, WB_RegWrite_DM_WB, forwardA, forwardB);

input [3:0] EX_Rs_Addr_ID_EX, EX_Rt_Addr_ID_EX, WB_dst_addr_EX_DM, WB_dst_addr_DM_WB;
input WB_RegWrite_EX_DM, WB_RegWrite_DM_WB;
output reg [1:0] forwardA, forwardB;

localparam NO_HAZARD  = 2'b00;
localparam EX_HAZARD  = 2'b10;
localparam MEM_HAZARD = 2'b01;

always @(*) begin
	if ((WB_RegWrite_EX_DM && |WB_dst_addr_EX_DM) && (WB_dst_addr_EX_DM == EX_Rs_Addr_ID_EX)) begin
		forwardA <= EX_HAZARD;
	end else if ((WB_RegWrite_DM_WB && |WB_dst_addr_DM_WB) && (WB_dst_addr_DM_WB == EX_Rs_Addr_ID_EX)) begin
		forwardA <= MEM_HAZARD;
	end else begin
		forwardA <= NO_HAZARD;
	end
	if ((WB_RegWrite_EX_DM & |WB_dst_addr_EX_DM) & (WB_dst_addr_EX_DM == EX_Rt_Addr_ID_EX)) begin
		forwardB <= EX_HAZARD;
	end else if ((WB_RegWrite_DM_WB && |WB_dst_addr_DM_WB) && (WB_dst_addr_DM_WB == EX_Rt_Addr_ID_EX)) begin
		forwardB <= MEM_HAZARD;
	end else begin
		forwardB <= NO_HAZARD;
	end
end

endmodule











module JR_forward(ctrl_jr, id_rs, ex_rd, forward);

input [3:0] id_rs, ex_rd;
input ctrl_jr;
output reg forward;

localparam FORWARD    = 1'b1;
localparam NO_FORWARD = 1'b0;

always @(*) begin
	forward = (ctrl_jr && (id_rs == ex_rd)) ? FORWARD : NO_FORWARD;
end

endmodule
