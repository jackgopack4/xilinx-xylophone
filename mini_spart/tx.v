
//////////////////////////////////////////////////////////////////////////////////////////
// Company: UW Madison 
// Engineers: Tim Zodrow, Manjot S Pal, Jack
// 
// Create Date: 2/2/2015  
// Design Name: mini-spart
// Module Name:    tx
// Project Name: miniproject1
// Target Devices: FPGA
// Description: This is a simple module which transmit the data. This is done with the 
//help of some select signals which when asserted uses the sequential logic to count the 
//number of enable signals and the correct number of shifts.

//////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////
// Inputs, outputs //
////////////////////
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

//creating two states in order to carryout transmit
localparam IDLE = 1'b0;
localparam TRANS = 1'b1;

//10 bit receive buffer (including start and stop bit)
reg [9:0] receive_buffer;
//4 bit counter for counting enable signals and number of shifts
reg [3:0] en_counter, shft_counter;

//registers for different signals for sequential logic on which transmit takes place
reg state, nxt_state;
reg shft_start, shft_tick;
reg en_start, en_tick;
reg load, shft;

//////////////
// State FF //
//////////////
//always block for current state and next state set on posedge clk and rst
always @ (posedge clk, posedge rst)
	if(rst)
		state <= IDLE;
	else
		state <= nxt_state;

////////////////////
// Receive Buffer //
////////////////////
//always block for receive buffer for the data it gets depending on which signal is 
//set set on posedge clk and rst
always @ (posedge clk, posedge rst)
	if(rst)
		receive_buffer <= 10'h001;
	else if (load)
		receive_buffer <= {1'b1,data,1'b0};
	else if (shft)
		receive_buffer <= {1'b1, receive_buffer[9:1]};
	
////////////////////////////////
// Enable (baud tick) counter //
////////////////////////////////

//always block for downcounting the enable signals set on posedge clk and rst		
always @ (posedge clk, posedge rst)
	if(rst)
		en_counter <= 4'h0;
	else if(en_start)
		en_counter <= 4'hF;
	else if(en_tick)
		en_counter <= en_counter - 1;

///////////////////////
// Shift reg counter //
///////////////////////
//always block for counting the number of shifts set on posedge clk and rst
always @ (posedge clk, posedge rst)
	if(rst)
		shft_counter <= 4'h0;
	else if(shft_start)
		shft_counter <= 4'h9;
	else if(shft_tick)
		shft_counter <= shft_counter - 1;

//TxD always gets LSB of receive_buffer
assign TxD = receive_buffer[0];

//setting up defaults
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
			//setting different signals when en_tx is asserted and transmitting to TRANS state 
			if(en_tx) begin
				load = 1;
				en_start = 1;
				shft_start = 1;
				nxt_state = TRANS;
			end
		end
		TRANS : begin
			tbr = 0;
			if(en) begin						// Enable signal detected
				if(~(|en_counter)) begin			// All enable signals detected (16)
					if(~(|shft_counter)) begin		// All bits transfered so transmission to IDLE
						nxt_state = IDLE;
					end
					else begin				//if all bits not transfered then stay in TRANS
						en_start = 1;			//state to transfer rest of the bits
						shft_tick = 1;
						shft = 1;
						nxt_state = TRANS;
					end
				end
				else begin
					en_tick = 1;				//if enable counter is not full, stay in trans to
					nxt_state = TRANS;			//count the rest of the enable signals
				end
			end
			else begin
				nxt_state = TRANS;				//if enable signal is not asserted, stay in TRANS
			end
		end
	endcase
end	

endmodule
	