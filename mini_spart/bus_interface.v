//////////////////////////////////////////////////////////////////////////////////////////
// Company: UW Madison 
// Engineers: Tim Zodrow, Manjot S Pal, Jack
// 
// Create Date: 2/2/2015  
// Design Name: mini-spart
// Module Name:    bus_interface 
// Project Name: miniproject1
// Target Devices: FPGA
// Description: The Bus Interface constitutes a 3 state buffer which connects the SPART to 
//the DATABUS. It contains combinational logic for the selecting the lower or higher bits. 
//It utilizes IOCS and IOR/W signals to make sure that 3 state drivers don't in conflict with 
//other drivers on DATABUS.

//////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////
// Inputs, outputs //
////////////////////
module bus_interface(
	input iocs,
	input iorw,
	input [1:0] ioaddr,
	input rda,
	input tbr,
	input [7:0] databus_in,
	output reg [7:0] databus_out,
	input [7:0] data_in,
	output reg [7:0] data_out,
	output reg wrt_db_low,
	output reg wrt_db_high,
	output reg wrt_tx,
	output reg rd_rx,
	output reg databus_sel
	);
	
//defaulting/initializing the signals 
	always @ (*) begin
		data_out = 8'h00;
		wrt_db_low = 0;
		wrt_db_high = 0;
		wrt_tx = 0;
		databus_sel = 0;
		databus_out = 8'h00;
		rd_rx = 0;

//getting into different cases only when chip select is high
		if(iocs) begin
			case(ioaddr)
				2'b00 : begin
					// Recieve Buffer
					if(iorw) begin
						databus_sel = 1;
						databus_out = data_in;
						rd_rx = 1;
					end
					// Transmit Buffer
					else begin
						data_out = databus_in;
						wrt_tx = 1;
					end
				end
				2'b01 : begin
					//Status register
					if(iorw) begin
						//setting the databus select high
						databus_sel = 1;
						databus_out = {6'b000000, rda, tbr};
					end
				end
				2'b10 : begin
					//low division buffer
					data_out = databus_in;
					wrt_db_low = 1;		//setting the low bits signal high to indicate to fill out the lower bits
				end
				2'b11 : begin
					//high division buffer
					data_out = databus_in;
					wrt_db_high = 1;	//setting the high bits signal high to indicate to fill out the higher bits
				end
			//ending the case statement
			endcase
		end
	end
endmodule