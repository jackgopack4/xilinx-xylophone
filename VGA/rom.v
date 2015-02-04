`timescale 1ns / 1ps
// Comments
module rom(
	input clk,
	input rst,
	input [12:0] addr, 
	output [23:0] rdata);
	
	parameter ADDR_WIDTH = 13;
	parameter DATA_WIDTH = 24;
	parameter MEM_FILE = "tiny_image.coe";

	reg [DATA_WIDTH-1:0] ROM [0:2**ADDR_WIDTH-1];
	initial $readmemh(MEM_FILE, ROM);
	always @ (posedge clk, posedge rst)
		if(rst)
			rdata <= 0;
		else
			rdata <= ROM[addr];

endmodule