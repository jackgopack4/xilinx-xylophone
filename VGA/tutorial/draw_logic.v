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
`define PADDLE_WIDTH 10'd8
`define PADDLE_HEIGHT 10'd48
`define BALL_WIDTH 10'd16
`define BALL_HEIGHT 10'd16

`define PLAY_TOP 10'd8
`define PLAY_BOTTOM 10'd471
`define PLAY_LEFT 10'd8
`define PLAY_RIGHT 10'd631

module draw_logic(clk, rst, pixel_x, pixel_y, pixel_r, pixel_g, pixel_b,multiplier, multiplicand, product);
    input clk;
    input rst;
    input [9:0] pixel_x;
    input [9:0] pixel_y;
	 
    output reg [7:0] pixel_r;
    output reg [7:0] pixel_g;
    output reg [7:0] pixel_b;
	 
	wire [11:0] rom_addr;
	wire [23:0] rom_color;
	 
		
		
    wire [3:0] next_pixy;
	wire [3:0] next_pixx;
	 
	assign next_pixy = pixel_y+4'h1;
	assign next_pixx = pixel_x+4'h1;
    
	assign rom_addr = {next_pixy,cur_digit,next_pixx};
	 
    simple_rom #(12,24,"numbers.mem") num_rom(clk, rom_addr, rom_color);

    always@(*) begin
		pixel_r = 8'h00;
		pixel_g = 8'h00;
		pixel_b = 8'h00;
		if(~rst) begin
		  if(pixel_x < 128 && pixel_y==31) begin
				pixel_r = 8'hC0;
				pixel_g = 8'hC0;
				pixel_b = 8'hFF;
		  end else if(pixel_x<128 && pixel_y <48) begin
				pixel_r = rom_color[23:16];
				pixel_g = rom_color[15:8];
				pixel_b = rom_color[7:0];
		  end
		end
	 end
	 
	 
endmodule
