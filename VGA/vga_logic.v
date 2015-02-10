`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ECE554
// Engineer: Manjot Pal, John Peterson, Tim Zodrow
// 
// Create Date:    16:37:45 02/10/2014 
// Design Name: 	
// Module Name:    vga_logic 
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
// Takes in clk and start signal; outputs timing signals for horizontal and vertical
// Including blank time and front/back porch, etc.
//////////////////////////////////////////////////////////////////////////////////
module vga_logic(clk, rst, blank, comp_sync, hsync, vsync, pixel_x, pixel_y, start);
    input clk;
    input rst;
    input start; // wait until this signal high to do anything
	output blank;
	output comp_sync;
    output hsync;
    output vsync;
    output [9:0] pixel_x;
    output [9:0] pixel_y;
	 
	reg [9:0] pixel_x;
	reg [9:0] pixel_y;
	 
	// pixel_count logic
	wire [9:0] next_pixel_x;
	wire [9:0] next_pixel_y;
	assign next_pixel_x = (pixel_x == 10'd799)? 0 : pixel_x+1;
	assign next_pixel_y = (pixel_x == 10'd799)?
	                             ((pixel_y == 10'd520) ? 0 : pixel_y+1)
										  : pixel_y;
	 
	// Handle reset or delay, assign pixel value
	always@(posedge clk, posedge rst) begin
	   if(rst) begin
		  pixel_x <= 10'h0;
		  pixel_y <= 10'h0;
		end else if(!start) begin
		  pixel_x <= 10'h0;
		  pixel_y <= 10'h0;
		end
		else begin
		  pixel_x <= next_pixel_x;
		  pixel_y <= next_pixel_y;
		end
	end
	// Assign timing value to signals based on which value we are at
	assign hsync = (pixel_x < 10'd656) || (pixel_x > 10'd751); // 96 cycle pulse
	assign vsync = (pixel_y < 10'd490) || (pixel_y > 10'd491); // 2 cycle pulse
	assign blank = ~((pixel_x > 10'd639) | (pixel_y > 10'd479));
	assign comp_sync = 1'b0; // don't know, dont use
	 
endmodule
