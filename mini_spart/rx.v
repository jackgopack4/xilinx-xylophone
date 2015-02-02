module rx(
	input clk,
	input rst_n,
	input RxD,
	input Enable,
	output reg RDA,
	output reg [7:0] RxD_data
	);
	reg [3:0] RxD_state, RxD_count, nxt_state;
	reg [1:0] RxD_sync;
	always @(posedge clk) if(BitTick) RxD_sync <= {RxD_sync[0], RxD};
	reg [1:0] Filter_cnt;
	reg RxD_bit, RxD_prev;
	reg TickUp;

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			RxD_sync = 2'b11;
			Filter_cnt = 2'b11;
			RxD_bit = 1'b1;
			RxD_count = 0;
		end
		RxD_bit = RxD;
		if(Enable) begin
			RxD_prev = RxD_bit;
			RxD_bit = RxD;
			RxD_count = RxD_count + 1;
			if(RxD_count == 16) begin
				RxD_count = 0;
				TickUp = 1;
			end
		end
		if(RxD_prev && !RxD_bit && RxD_state == 0) begin
			// this means reception started
			RxD_count = 0;
			RxD_state = 1; // receiving
		end
	end

	always @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			nxt_state <= 0;
			RxD_state <= 0;
		end
		RxD_state <= nxt_state;
	end


endmodule