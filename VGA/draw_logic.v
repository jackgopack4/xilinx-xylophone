`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ECE554
// Engineer: Manjot Pal, John Peterson, Tim Zodrow
// 
// Create Date:    16:39:31 02/10/2014 
// Design Name: 
// Module Name:    draw_logic 
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
// assigns pixel values based on rom data and timing
//////////////////////////////////////////////////////////////////////////////////

module draw_logic(clk, rst, pixel_x, pixel_y, pixel_r, pixel_g, pixel_b, rom_color, fifo_empty);
    input clk;
    input rst;
    input [9:0] pixel_x;
    input [9:0] pixel_y;
    input fifo_empty;
    input [23:0] rom_color;
	 
    output reg [7:0] pixel_r;
    output reg [7:0] pixel_g;
    output reg [7:0] pixel_b;

	 // Write using State Machine waiting for correct signal to start displaying
    always@(*) begin
		pixel_r = 8'h00;
		pixel_g = 8'h00;
		pixel_b = 8'h00;
		if(~rst) begin
		  if(!fifo_empty) begin
				pixel_r = rom_color[23:16];
				pixel_g = rom_color[15:8];
				pixel_b = rom_color[7:0];
		  end
		end
	 end
	 
	 
endmodule

