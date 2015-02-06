`timescale 1ns / 1ps
// Comments
module rom(
	input clk,
	input rst,
	input [23:0] addr, 
	output reg [23:0] rdata);
	

	parameter DISPLAY_HEIGHT = 640;
	parameter DISPLAY_WIDTH = 480;
	parameter DATA_WIDTH = 24;
	parameter MEM_FILE = "tiny_image.coe";

	reg [DATA_WIDTH-1:0] ROM [0:DISPLAY_HEIGHT*DISPLAY_WIDTH-1];
	initial $readmemh(MEM_FILE, ROM);
	always @ (posedge clk, posedge rst)
		if(rst)
			rdata <= 0;
		else
			rdata <= ROM[addr];

endmodule