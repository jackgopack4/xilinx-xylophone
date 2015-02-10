`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ECE554
// Engineer: Manjot Pal, John Peterson, Tim Zodrow
// 
// Create Date:    18:09:18 02/04/2015 
// Design Name: 
// Module Name:    fifo 
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
module fifo(
    output full,
    output empty,
    input [23:0]data_in,
    output [23:0]data_out,
    input clk,
    input rst,
    input rd
    );
	 

	reg wrt_en, rd_en;
	reg [3:0] wrt_addr, rd_addr, status_counter;
	reg [23:0] mem [0:15];
	
	always@(posedge clk, posedge rst)
		if(rst)
			status_counter <= 4'h0;		
		else if(wrt_en && !(rd_en))	
			 status_counter <= status_counter + 1;		 
		else if(!wrt_en &&(rd_en) && |(status_counter))		//not writing, reading and status counter is empty
			 status_counter <= status_counter - 1;
			

	always@(posedge clk, posedge rst)
		if(rst)
			wrt_addr <= 24'h0;
		else if(write_en && !full)
			wrt_addr <= wrt_addr + 1;
			
	always@(posedge clk, posedge rst)
		if(rst)
			mem[wrt_addr] <= 24'h0;
		else if(write_en && !full)
			mem[wrt_addr] <= data_in;
			
	always@(posedge clk, posedge rst)
		if(rst)
			rd_addr <= 24'h0;
		else if (rd_en && !empty)
			rd_addr <= rd_addr + 1;
			
			
	assign full = (status_counter == 4'hF);
	assign empty = ~|(status_counter);
	assign data_out = mem[rd_addr];
			

endmodule
