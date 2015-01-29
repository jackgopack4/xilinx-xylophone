module bus_interface(
	input iocs,
	input iorw,
	input [1:0] ioaddr,
	input rda,
	input tbr,
	input [7:0] databus_in,
	output [7:0] databus_out,
	input [7:0] data_in,
	output [7:0] data_out,
	output wrt_db_low,
	output wrt_db_high,
	output wrt_tx,
	output databus_sel
	);
	
	always @ (*) begin
		data_out = 8'h00;
		wrt_db_low = 0;
		wrt_db_high = 0;
		wrt_tx = 0;
		databus_sel = 0;
		databus_out = 8'h00;
		if(iocs) begin
			case(ioaddr)
				2'b00 : begin
					// Recieve Buffer
					if(iorw) begin
						databus_out = data_in;
					end
					// Transmit Buffer
					else begin
						data_out = databus_in;
						wrt_tx = 1;
					end
				end
				2'b01 : begin
					if(iorw) begin
						databus_out = {6'b000000, rda, tbr};
					end
				end
				2'b10 : begin
					data_out = databus_in;
					wrt_db_low = 1;
				end
				2'b11 : begin
					data_out = databus_in;
					wrt_db_high = 1;
				end
			endcase
		end
	end
endmodule