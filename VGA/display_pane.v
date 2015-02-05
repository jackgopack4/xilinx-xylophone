`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:26:39 02/04/2015 
// Design Name: 
// Module Name:    display_pane 
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
module display_pane(
    input clk,
    input rst,
    input [23:0] data_in,
    input empty,
    input full,
    output [23:0] mem_addr,
    output [23:0] data_out
    );

	reg [2:0] h_count, v_count;
	reg [7:0] x_count;
	reg [23:0] curr_addr, start_addr;

	reg rst_curr_addr, rst_x_count;
	reg inc_curr_addr, inc_v_count, inc_x_count, inc_h_count;
	reg load_start_addr;

	reg state, nxt_state; 

	always @ (posedge clk, posedge rst)
		if(rst)
			curr_addr <= 24'h0;
		else if(rst_curr_addr)
			curr_addr <= start_addr;
		else if(inc_curr_addr)
			curr_addr <= curr_addr + 1

	always @ (posedge clk, posedge rst)
		if(rst)
			start_addr <= 24'h0;
		else if(load_start_addr)
			start_addr <= curr_addr + 1;

	always @ (posedge clk, posedge rst)
		if(rst)
			h_count <= 4'h0;
		else if(inc_h_count)
			h_count <= h_count + 1;

	always @ (posedge clk, posedge rst)
		if(rst)
			v_count < 4'h0;
		else (inc_v_count)
			v_count <= v_count + 1;

	always @ (posedge clk, posedge rst)
		if(rst)
			x_count <= 8'h00;
		else if(rst_x_count)
			x_count <= 8'h00;
		else if(inc_x_count)
			x_count <= x_count + 1;

	assign data_out = data_in;
	assign mem_addr = curr_addr;

	always @ (*) begin
		nxt_state = LOAD;
		rst_curr_addr = 0;
		rst_x_count = 0;
		inc_curr_addr = 0;
		inc_v_count = 0; 
		inc_x_count = 0; 
		inc_h_count = 0;
		load_start_addr = 0;

		case(state)
			LOAD : begin
				if(~full) begin
					rst_x_count = (x_count == 8'h50);
					rst_curr_addr = rst_x_count;

					inc_h_count = 1;
					inc_x_count = &h_count;
					inc_v_count = rst_x_count;

					curr_addr = inc_x_count;
					load_start_addr = (&v_count) & rst_x_count;
				end
				else
					nxt_state = WAIT;
			end
			WAIT : begin
				if(~empty)
					nxt_state = WAIT;
			end
		endcase
	end	
endmodule
