`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////
// Company: UW Madison 
// Engineers: Tim Zodrow, Manjot S Pal, Jack
// 
// Create Date: 2/2/2015  
// Design Name: mini-spart
// Module Name: driver 
// Project Name: miniproject1
// Target Devices: FPGA
// Description: The driver starts initializes and drives the sparts transactions and receives
// data from the databus. It sets the baud rate from the br_cfg and sends out signals to 
// capture the data from the spart and send data back.

//////////////////////////////////////////////////////////////////////////////////////////////
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

    //////////////////////////////
    // States for State Machine //
    //////////////////////////////
    localparam INIT_LOW_DB = 2'b00;
    localparam INIT_HIGH_DB = 2'b01;
    localparam RECEIVE = 2'b11;
    localparam RECEIVE_WAIT = 2'b10;

    ////////////////////////////////////////
    // Registers used for control signals //
    ////////////////////////////////////////
    reg sel,wrt_rx_data;

    // State Registers
    reg [2:0] state, nxt_state;
    // Data Registers
    reg [7:0] data_out, rx_data;

    // Tri-state buffer used to receive and send data via the databuse
    // Sel high = output, Sel low = input
	assign databus = sel ? data_out : 8'bz;
	
    // RX Received Data Flop
	always  @ (posedge clk, posedge rst) begin
		if(rst)
			rx_data <= 8'h00;
		else if (wrt_rx_data)
			rx_data <= databus;
	end
	
    // State Flop
	always @ (posedge clk, posedge rst) begin
		if(rst)
			state <= 2'b00;
		else
			state <= nxt_state;
	end

	///////////////////
    // State Machine //
    ///////////////////
    always@(*) begin
        // Initializations
		ioaddr = 2'b00;
		sel = 0;
		iocs = 1;
		iorw = 1;
		nxt_state = INIT_LOW_DB;
		data_out = 8'h00;
		wrt_rx_data = 0;
		
		case(state)
            // Write the lower byte to Baud Gen
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
			// Write the higher byte to Baud Gen
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
			// Wait for receive data to be read
			RECEIVE_WAIT: begin
					if(~rda) begin
						nxt_state = RECEIVE_WAIT;
						iocs = 0;
					end
					else begin
						nxt_state = RECEIVE;
						wrt_rx_data = 1;
						ioaddr = 2'b00;
					end
			end
			// Send receive data to TX when TX is ready for data
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
