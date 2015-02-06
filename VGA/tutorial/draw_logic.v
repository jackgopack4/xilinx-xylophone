`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:39:31 02/10/2014 
// Design Name: 
// Module Name:    draw_logic 
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

module draw_logic(clk, rst, pixel_x, pixel_y, pixel_r, pixel_g, pixel_b, rom_color, read_en, fifo_empty);
    input clk;
    input rst;
    input [9:0] pixel_x;
    input [9:0] pixel_y;
    input fifo_empty;
	 
    output reg [7:0] pixel_r;
    output reg [7:0] pixel_g;
    output reg [7:0] pixel_b;

    output reg read_en;
	 
	wire [11:0] rom_addr;
	input [23:0] rom_color;
	 
		
		
    wire [3:0] next_pixy;
	wire [3:0] next_pixx;
	 
	assign next_pixy = pixel_y+4'h1;
	assign next_pixx = pixel_x+4'h1;

    always@(*) begin
		pixel_r = 8'h00;
		pixel_g = 8'h00;
		pixel_b = 8'h00;
		read_en = 1'b0;
		if(~rst) begin
		  if(!fifo_empty) begin
		  		read_en = 1'b1;
				pixel_r = rom_color[23:16];
				pixel_g = rom_color[15:8];
				pixel_b = rom_color[7:0];
		  end
		end
	 end
	 
	 
endmodule
