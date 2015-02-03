`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:39:06 02/10/2014 
// Design Name: 
// Module Name:    main_logic 
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
module main_logic(clk, rst, up, down, left, right, pixel_x, pixel_y, pixel_r, pixel_g, pixel_b);
    input clk;
    input rst;
    input up;
    input down;
	 input left;
	 input right;
    input [9:0] pixel_x;
    input [9:0] pixel_y;
    output [7:0] pixel_r;
    output [7:0] pixel_g;
    output [7:0] pixel_b;
	 
	 wire tick_cycle;
	 wire [19:0] tick_counter;
	 
	 wire [31:0] multiplier;
	 wire [31:0] multiplicand;
	 wire [31:0] product;
	 
	 draw_logic draw1(clk, rst, pixel_x, pixel_y,  
	                  pixel_r, pixel_g, pixel_b,multiplier, multiplicand, product);
     
	 tick_logic tl1(clk, rst, tick_cycle,
                   up, down, left, right,	 
	                multiplier, multiplicand, product);
					
	 
	 up_counter uc1(rst | tick_cycle, clk, tick_counter);
	
	 assign tick_cycle = (tick_counter == 20'h80000);

endmodule
