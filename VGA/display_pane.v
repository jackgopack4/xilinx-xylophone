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

	localparam IDLE = 2'b00;
	localparam READ = 2'b01;
	//localparam IDLE = 2'b000;
	//localparam IDLE = 2'b000;

	reg [1:0] state, nxt_state;
	reg inc_addr;
	reg [23:0] load_addr;
	
	assign data_out = data_in;
	assign mem_addr = load_addr;
	
	always@(posedge clk, posedge rst)
		if(rst)
			state <= 3'b000;
		else
			state <= nxt_state;

	always@(posedge clk, posedge rst)
		if(inc_addr)
			load_addr <= 24'h0;
		else
			load_addr <= load_addr + 1;
			
			
	always begin
		inc_addr = 0;
		nxt_state = IDLE;
		case(state)
				
					IDLE: if(empty) begin
								nxt_state = READ;
								inc_addr = 1;
							end
		
					READ: if(!full) begin
								nxt_state = READ;
								inc_addr = 1;	
							end
			endcase
		
		end
		
endmodule
