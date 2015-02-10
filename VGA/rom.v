`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ECE554
// Engineer: Manjot Pal, John Peterson, Tim Zodrow
// 
// Create Date:    17:26:39 02/04/2015 
// Design Name: 
// Module Name:    rom 
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
// Reads data from small 80x60 image in memory
//////////////////////////////////////////////////////////////////////////////////
module rom(
	input clk,
	input rst,
	input [12:0] addr, 
	output reg [23:0] rdata);
	

	parameter DISPLAY_HEIGHT = 640;
	parameter DISPLAY_WIDTH = 480;
	parameter DATA_WIDTH = 24;
	parameter MEM_FILE = "tiny_image.coe";

	reg [DATA_WIDTH-1:0] rom [0:DISPLAY_HEIGHT*DISPLAY_WIDTH-1];
	// initial $readmemh(MEM_FILE, ROM);
	initial $readmemh("memory.list", rom);
	always @ (posedge clk, posedge rst)
		if(rst)
			rdata <= 0;
		else
			rdata <= rom[addr];

endmodule
