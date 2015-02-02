`timescale 1ns / 1ps
module rx(
		clk,
		rst,
		RxD,
		Baud,
		RxD_data,
		RDA,
		rd_rx
		);
	////////////
	// Inputs //
	////////////
	input clk, rst, RxD, Baud, rd_rx;

	/////////////
	// Outputs //
	/////////////
	output [7:0] RxD_data;
	output reg RDA;

	////////////
	// States //
	////////////
	parameter IDLE = 2'b00;
	parameter STRTBIT = 2'b01;
	parameter RCV = 2'b10;
	parameter DONE = 2'b11;
	reg [1:0] state, nxt_state;

	///////////////
	// Registers //
	///////////////
	reg RxD_ff1, RxD_ff2;
	reg shift;
	reg [7:0] RxD_shift;
	reg [3:0] bit_cnt;
	reg [4:0] baud_cnt;

	/////////////
	// Signals //
	/////////////
	wire negedgeRxD;
	reg rst_bit_cnt, rst_baud_cnt;

	// shift when baud cnt = 16;
	// assign shift = (baud_cnt == 5'b10000);
	// buffer for shift is 4 baud ticks (1/4 of period)
	assign strt_shift = (baud_cnt == 5'b01000);
	// Detect negative edge of RX for start signal
	assign negedgeRxD = (~RxD_ff1 && RxD_ff2);
	// Set output data
	assign RxD_data = RxD_shift;

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

	////////////////////
	// Bit counter FF //
	////////////////////
	always@(posedge clk, posedge rst) begin
		if(rst)
			bit_cnt <= 4'h0;
		else if(rst_bit_cnt) begin
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
		if(rst)
			baud_cnt <= 5'h0;
		else if(rst_baud_cnt) begin
			baud_cnt <= 5'h0;
		end
		else if(Baud) begin
			baud_cnt <= baud_cnt + 1;
		end
	end

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
		RDA = 0;
		nxt_state = IDLE;
		shift = 0;
		
		case(state)
			IDLE: begin
				if(negedgeRxD) begin
					nxt_state = STRTBIT;
				end
			end
			STRTBIT: begin
				if(strt_shift) begin
					rst_baud_cnt = 1;
					shift = 1;
					rst_bit_cnt = 1;
					nxt_state = RCV;
				end
				else nxt_state = STRTBIT;
			end
			RCV: begin
				if(baud_cnt == 5'b10000) begin
					shift = 1;
					rst_baud_cnt = 1;
					if(bit_cnt == 4'h7) begin
						nxt_state = DONE;
					end
					else begin
						nxt_state = RCV;
					end
				end
				else nxt_state = RCV;
			end
			DONE : begin
				if(rd_rx)
					nxt_state = IDLE;
				else begin
					nxt_state = DONE;
					RDA = 1;
				end
			end
		endcase
	end

endmodule