`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:06:17 01/29/2015 
// Design Name: 
// Module Name:    baud_rate_gen 
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
module baud_rate_gen(tx_ben, rx_ben, clk, rst, enable, data, write, sel_low, sel_high);

input clk, rst, enable;
input [7:0] data;  //for divisor

output tx_bd_en, rx_bd_en;  //baud enable for transmitting and receiving 

reg [15:0] divisor_buffer, rx_bd_cnt, tx_bd_cnt; //counters for tx and rx

reg [32:0] divisor;

always @ (posedge clk, posedge rst)
	if(rst)
		divisor_buffer <= 16'h0000;
	else if(sel_low)
		divisor_buffer <= {divisor_buffer[15:8], data};
	else if(sel_high)
		divisor_buffer <= {data, divisor_buffer[7:0]};
		
		// TODO HARDWIRE VALUES

assign 
endmodule
