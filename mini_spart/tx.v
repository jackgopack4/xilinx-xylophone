////////////////////////////////////////////////////////
// RS-232 TX module
// The RS-232 settings are fixed
// Start, 8-bit data, two stop

////////////////////////////////////////////////////////
module tx(
	input clk,
	input rst_n,
	input TxD_start,
	input Enable,
	input [7:0] TxD_data,
	output TxD,
	output TBR
);

// Assert TxD_start for (at least) one clock cycle to start transmission of TxD_data
// TxD_data is latched so that it doesn't have to stay valid while it is being sent

reg TxD_state;
wire TBR = (TxD_state==0);
reg [3:0] EnableCnt;
reg [3:0] StateCnt;
reg Sample;

always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		Sample <= 0;
		EnableCnt <= 0;
		StateCnt <= 0;
		TxD_state <= 1'b0;
	end
	Sample <= 0;
	if(Enable) begin
		if(EnableCnt == 15) begin
			EnableCnt <= 0;
			Sample <= 1;
		end
		else begin
			EnableCnt <= EnableCnt + 1;
		end
		$display("EnableCnt = %b", EnableCnt);
	end
	if(Sample) begin
		if(StateCnt == 4'b1010) begin
			StateCnt <= 0;
		end
		else begin
			if(TxD_state == 1'b1) begin
				StateCnt <= StateCnt + 1;
				TxD_shift <= (TxD_shift >> 1);
			end
		end
		$display("StateCnt = %b", StateCnt);
	end
	if(TBR & TxD_start)
		TxD_shift <= TxD_data;
		$display("data latched");
end

reg [7:0] TxD_shift = 0;
always @(posedge clk, negedge rst_n)
begin
	if(!rst_n) begin
		TxD_state <= 1'b0;
	end
	if(TBR & TxD_start)
		TxD_shift <= TxD_data;
	else
	if(TxD_state == 1'b1; & Sample)
		TxD_shift <= (TxD_shift >> 1);

	case(TxD_state)
		1'b0: if(TxD_start) TxD_state <= 1'b1; // idle
		1'b1: if(Sample) begin // transmit
			if(StateCnt < 10) TxD_state <= 1'b1;
			else TxD_state <= 1'b0
		end
		default: TxD_state <= 1'b0;
	endcase
end

assign TxD = (TxD_state == 1'b1 && !(StateCnt >= 4'b1001) && (StateCnt == 4'b0001 | TxD_shift[0]));  // put together the start, data and stop bits
endmodule