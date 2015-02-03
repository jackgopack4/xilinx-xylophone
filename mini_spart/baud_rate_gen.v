`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:06:17 01/29/2015 
// Design Name: 
// Module Name:    baud_rate_gen 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module baud_rate_gen(
	input clk, 
	input rst, 
	output reg en, 
	input [7:0] data, 
	input sel_low, 
	input sel_high
	);

reg [15:0] divisor_buffer;
reg state, nxt_state;
reg load_counter, en_counter;
reg [11:0] counter, counter_start;



localparam SEND_SIGNAL = 0;
localparam WAIT = 1;

always @ (posedge clk, posedge rst)
	if(rst)
		divisor_buffer <= 16'h0000;
	else if(sel_low)
		divisor_buffer <= {divisor_buffer[15:8], data};
	else if(sel_high)
		divisor_buffer <= {data, divisor_buffer[7:0]};
		
always @ (posedge clk, posedge rst)
	if(rst)
		state <= SEND_SIGNAL;
	else
		state <= nxt_state;
		
always @ (posedge clk, posedge rst)
	if(rst)
		counter <= 12'h000;
	else if(load_counter)
		counter <= counter_start;
	else if(en_counter)
		counter <= counter - 1;
		
always @ (*) begin
	counter_start = 0;
	case(divisor_buffer[15:12])
		4'h1 : counter_start = 12'h515;
		4'h2 : counter_start = 12'h28B;
		4'h4 : counter_start = 12'h145;
		4'h9 : counter_start = 12'h0A3;
	endcase
end


always @ (clk, rst, state, counter) begin
	en = 0;
	load_counter = 0;
	en_counter = 0;
	nxt_state = SEND_SIGNAL;
	case(state)
		SEND_SIGNAL : begin
			en = 1;
			load_counter = 1;
			nxt_state = WAIT;
		end
		WAIT : begin
			if(~(|counter))
				nxt_state = SEND_SIGNAL;
			else begin
				en_counter = 1;
				nxt_state = WAIT;
			end
		end
	endcase
end
endmodule
