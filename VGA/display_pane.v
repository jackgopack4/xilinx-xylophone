`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ECE554
// Engineer: Manjot Pal, John Peterson, Tim Zodrow
// 
// Create Date:    17:26:39 02/04/2015 
// Design Name: 
// Module Name:    display_pane 
// Project Name: Miniproject 2 - VGA
// Target Devices: Virtex-5
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
// Write data to FIFO from ROM. Operates at 100MHz
//////////////////////////////////////////////////////////////////////////////////
module display_pane(
    input clk,
    input rst,
    input [23:0] data_in,
    input empty,
    input full,
    output reg write_en,
    output [12:0] mem_addr,
    output [23:0] data_out
    );
	
	// States
	localparam WAIT = 1'b0;
	localparam LOAD = 1'b1;

	// Flop registers
	reg [2:0] h_count, v_count;
	reg [7:0] x_count;
	reg [12:0] curr_addr, start_addr;

	// Control Signals
	reg rst_curr_addr, rst_x_count, rst_back_door, rst_addr;
	reg inc_curr_addr, inc_v_count, inc_x_count, inc_h_count;
	reg load_start_addr;

	// Wait counter for initialization
	reg [15:0] back_door;

	reg state, nxt_state;
	
	///////////
	// FLOPS //
	///////////
	always @ (posedge clk, posedge rst)
		if(rst)
			state <= 0;
		else
			state <= nxt_state;

	always @ (posedge clk, posedge rst)
		if(rst)
			curr_addr <= 13'h0;
		else if(rst_addr)
			curr_addr <= 13'h0;
		else if(rst_curr_addr)
			curr_addr <= start_addr;
		else if(inc_curr_addr)
			curr_addr <= curr_addr + 1;

	always @ (posedge clk, posedge rst)
		if(rst)
			start_addr <= 13'h0;
		else if(rst_addr)
			start_addr <= 13'h0;
		else if(load_start_addr)
			start_addr <= curr_addr;

	always @ (posedge clk, posedge rst)
		if(rst)
			h_count <= 4'h0;
		else if(inc_h_count)
			h_count <= h_count + 1;

	always @ (posedge clk, posedge rst)
		if(rst)
			v_count <= 4'h0;
		else if(inc_v_count)
			v_count <= v_count + 1;

	always @ (posedge clk, posedge rst)
		if(rst)
			x_count <= 8'h00;
		else if(rst_x_count)
			x_count <= 8'h00;
		else if(inc_x_count)
			x_count <= x_count + 1;

	always @ (posedge clk, posedge rst)
		if(rst)
			back_door <= 16'h0;
		else if(rst_back_door)
			back_door <= 16'h0;
		else
			back_door <= back_door + 1;

	// Assignments for outputs
	assign data_out = data_in;
	assign mem_addr = curr_addr;

	// State Machine
	always @ (*) begin
		// Initialization
		nxt_state = WAIT;
		rst_curr_addr = 0;
		rst_x_count = 0;
		inc_curr_addr = 0;
		inc_v_count = 0; 
		inc_x_count = 0; 
		inc_h_count = 0;
		load_start_addr = 0;
		write_en = 0;
		rst_back_door = 0;

		case(state)
			// Initialize FIFO 
			WAIT : begin
				if(&back_door)
					nxt_state = LOAD;
			end
			// Write data to FIFO
			LOAD : begin
				if(~full) begin
					// Always Set
					nxt_state = LOAD;
					write_en = 1;
					inc_h_count = 1;
					
					rst_x_count = (x_count == 8'h4f) & (&h_count); // Reset after a row is finished
					inc_curr_addr = (h_count == 4'h6); // Increase Address (Pre-Load 1 clock cycle before)
					rst_curr_addr = (x_count == 8'h4f) & inc_curr_addr & ~(&v_count); // Reset to the start of a row

					inc_x_count = &h_count; // End of Row
					inc_v_count = rst_x_count; // Repeated 8 Rows
 
					load_start_addr = (&v_count) & rst_x_count; // Load initial start of row (Stored in Start Address)
					
					rst_addr = (curr_addr == 13'h12bf) & inc_curr_addr & (x_count == 8'h4f) & (&v_count); // Reset Address at end of Picture (4800)
				end
				else begin
					nxt_state = LOAD;
				end
			end
		endcase
	end	
endmodule
