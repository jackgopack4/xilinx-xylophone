`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    driver 
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
module driver(
    input clk,
    input rst,
    input [1:0] br_cfg,
    output reg iocs,
    output reg iorw,
    input rda,
    input tbr,
    output reg [1:0] ioaddr,
    inout [7:0] databus
    );
	 
	 reg baud_rate;
	 reg [2:0] state, nxt_state;
	 reg sel,wrt_rx_data;
	 
	// localparam IDLE = 3'b000;
	 localparam INIT_LOW_DB = 2'b00;
	 localparam INIT_HIGH_DB = 2'b01;
	 localparam RECEIVE = 2'b11;
   // localparam TRANSMIT = 3'b100;
	 localparam RECEIVE_WAIT = 2'b10;
	 //localparam TRANSMIT_WAIT = 3'b110;
	 
	 
	 reg [7:0] a, data_out, rx_data;
	 wire [7:0] b;
	// Select high when writing to databus
	// reading from databus
	assign databus = sel ? data_out : 8'bz;
	assign b = databus;
	
/*
	always @ (posedge clk, posedge rst) begin
	
		if(rst) begin
			a <= 8'h00;
			b <= 8'h00;
			end
		else begin
			a <= data_out;
			b <= databus;
			end		
		
		end
*/
		
	always  @ (posedge clk, posedge rst) begin
		if(rst)
			rx_data <= 8'h00;
		else if (wrt_rx_data)
			rx_data <= b;
	end
	
	always @ (posedge clk, posedge rst) begin
		if(rst)
			state <= 2'b00;
		else
			state <= nxt_state;
	end

	 
	 always@(*) begin
		baud_rate = 16'h12c0; 				//default baud rate to 4800
		ioaddr = 2'b00;
		sel = 0;
		iocs = 1;
		iorw = 1;
		nxt_state = INIT_LOW_DB;
		data_out = 8'h00;
		wrt_rx_data = 0;
		
		/*
		case(br_cfg) 
	
		2'b00: 
				baud_rate = 16'h12c0;		//baud rate to 4800
				
		2'b01:
				baud_rate = 16'h2580;		//baud rate to 9600
				
		2'b10: 
				baud_rate = 16'h4b00;		//baud rate to 19200
				
		2'b11:
				baud_rate = 16'h9600;		//baud rate to 38400

		endcase
		*/
		
		case(state)
			INIT_LOW_DB: begin 
					ioaddr = 2'b10;
					sel = 1;
					nxt_state = INIT_HIGH_DB;
					case(br_cfg)	
						2'b00: 
								data_out = 8'hc0;		//baud rate to 4800
						2'b01:
								data_out = 8'h80;		//baud rate to 9600	
						2'b10: 
								data_out = 8'h00;		//baud rate to 19200	
						2'b11:
								data_out = 8'h00;		//baud rate to 38400
					endcase	
			end
			
			INIT_HIGH_DB: begin
					ioaddr = 2'b11;
					sel = 1;
					nxt_state = RECEIVE_WAIT;
					case(br_cfg)	
						2'b00: 
								data_out = 8'h12;		//baud rate to 4800
						2'b01:
								data_out = 8'h25;		//baud rate to 9600	
						2'b10: 
								data_out = 8'h4b;		//baud rate to 19200	
						2'b11:
								data_out = 8'h96;		//baud rate to 38400
					endcase	
			end
			
			RECEIVE_WAIT: begin
					if(~rda) begin
						nxt_state = RECEIVE_WAIT;
						iocs = 0;					// TODO: Maybe better to do this? -- TEST
						// ioaddr = 2'b00;
					end
					else begin
						nxt_state = RECEIVE;
						wrt_rx_data = 1;
						ioaddr = 2'b00;
					end
			end
			
			RECEIVE: begin
				if(tbr) begin
					nxt_state = RECEIVE_WAIT;					
					ioaddr = 2'b00;
					iorw = 0;
					data_out = rx_data;
					sel = 1;
				end
				else begin
					nxt_state = RECEIVE;
				end
			end
		endcase
	end		
endmodule
