module rx(
		clk,
		rst,
		RxD,
		Baud,
		RxD_data,
		RDA
		);
	////////////
	// Inputs //
	////////////
	input clk, rst, RxD, Baud;

	/////////////
	// Outputs //
	/////////////
	output reg [7:0] RxD_data;
	output reg RDA;

	////////////
	// States //
	////////////
	parameter IDLE = 2'b00;
	parameter STRTBIT = 2'b01;
	parameter RCV = 2'b10;
	parameter WAIT_RDY = 2'b11;
	reg [1:0] state, nxt_state;

	///////////////
	// Registers //
	///////////////
	reg RxD_ff1, RxD_ff2;
	reg [7:0] RxD_shift;
	reg [3:0] bit_cnt;
	reg [4:0] baud_cnt;

	/////////////
	// Signals //
	/////////////
	wire negedgeRxD;
	reg rst_bit_cnt, rst_baud_cnt, set_output;
	////////////////////
	// Double flop RX //
	////////////////////
	always@(posedge clk, posedge rst) begin
		if(rst) begin
			RxD_ff1 <= 1'b1;
			RxD_ff2 <= 1'b1;
		end
		else begin
			RxD_ff1 <= RxD;
			RxD_ff2 <= RxD_ff1;
		end
	end

	///////////////////////
	// RX shift register //
	///////////////////////
	always@(posedge clk, posedge rst) begin
		if(rst) begin
			RxD_shift <= 8'h00;
		end
		else if(shift) begin
			RxD_shift <= {RxD_ff2, RxD_shift[7:1]};
		end
	end

	// set RxD_data to rx shift register
	always@(posedge clk, posedge rst) begin
		if(rst) begin
			RxD_data <= 8'h00;
		end
		else if(set_output) RxD_data <= RxD_shift;
	end

	// Detect negative edge of RX for start signal
	assign negedgeRxD = (~RxD_ff1 && RxD_ff2);

	////////////////////
	// Bit counter FF //
	////////////////////
	always@(posedge clk, posedge rst) begin
		if(rst_bit_cnt | rst) begin
			bit_cnt <= 4'h0;
		end
		else if(shift) begin
			bit_cnt <= bit_cnt + 1;
		end
	end

	//////////////////////////
	// Baud tick counter FF //
	//////////////////////////
	always@(posedge clk, posedge rst) begin
		if(rst_baud_cnt | rst | (baud_cnt == 5'b10000)) begin
			baud_cnt <= 5'h0;
		end
		else if(Baud) begin
			baud_cnt <= baud_cnt + 1;
		end
	end

	// shift when baud cnt = 16;
	assign shift = (baud_cnt == 5'b10000);
	// buffer for shift is 4 baud ticks (1/4 of period)
	assign strt_shift = (baud_cnt == 5'b01000);

	//////////////
	// State FF //
	//////////////
	always@(posedge clk, posedge rst) begin
		if(rst) begin
			state <= IDLE;
		end
		else begin
			state <= nxt_state;
		end
	end

	always@(*) begin
		rst_bit_cnt = 0;
		rst_baud_cnt = 0;
		RDA = 1;
		set_output = 0;
		case(state)
			IDLE: begin
				rst_baud_cnt = 0;
				if(negedgeRxD) begin
					RDA = 0;
					nxt_state = STRTBIT;
				end
				else nxt_state = IDLE;
			end
			STRTBIT: begin
				RDA = 0;
				set_output = 1;
				if(strt_shift) begin
					rst_baud_cnt = 1;
					rst_bit_cnt = 1;
					nxt_state = RCV;
				end
				else nxt_state = STRTBIT;
			end
			RCV: begin
				RDA = 0;
				set_output = 1;
				if(shift) rst_baud_cnt = 1;
				if(bit_cnt == 4'h8) begin
					rst_baud_cnt = 1;
					nxt_state = IDLE;
				end
				else nxt_state = RCV;
			end
		endcase
	end

endmodule