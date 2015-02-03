`timescale 1ns / 1ps
module tx(
	input clk,
	input rst,
	input [7:0] data,
	input en,
	input en_tx,
	output reg tbr,
	output TxD
	);

localparam IDLE = 1'b0;
localparam TRANS = 1'b1;

reg [9:0] receive_buffer;
reg [3:0] en_counter, shft_counter;

reg state, nxt_state;
reg shft_start, shft_tick;
reg en_start, en_tick;
reg load, shft;

always @ (posedge clk, posedge rst)
	if(rst)
		state <= IDLE;
	else
		state <= nxt_state;

always @ (posedge clk, posedge rst)
	if(rst)
		receive_buffer <= 10'h3FF;
	else if (load)
		receive_buffer <= {1'b1,data,1'b0};
	else if (shft)
		receive_buffer <= {1'b1, receive_buffer[9:1]};
		
always @ (posedge clk, posedge rst)
	if(rst)
		en_counter <= 4'h0;
	else if(en_start)
		en_counter <= 4'hF;
	else if(en_tick)
		en_counter <= en_counter - 1;

always @ (posedge clk, posedge rst)
	if(rst)
		shft_counter <= 4'h0;
	else if(shft_start)
		shft_counter <= 4'h9;
	else if(shft_tick)
		shft_counter <= shft_counter - 1;

assign TxD = receive_buffer[0];

always @ (clk, rst, data, en) begin
	nxt_state = IDLE;
	load = 0;
	en_start = 0;
	en_tick = 0;
	shft_start = 0;
	shft_tick = 0;
	shft = 0;
	tbr = 0;
	case(state)
		IDLE : begin
			tbr = 1;
			if(en_tx) begin
				load = 1;
				en_start = 1;
				shft_start = 1;
				nxt_state = TRANS;
			end
		end
		TRANS : begin
			tbr = 0;
			if(en) begin								// Enable signal detected
				if(~(|en_counter)) begin			// All enable signals detected (16)
					if(~(|shft_counter)) begin		// All bits transfered
						nxt_state = IDLE;
					end
					else begin
						en_start = 1;
						shft_tick = 1;
						shft = 1;
						nxt_state = TRANS;
					end
				end
				else begin
					en_tick = 1;
					nxt_state = TRANS;
				end
			end
			else begin
				nxt_state = TRANS;
			end
		end
	endcase
end	

endmodule
	