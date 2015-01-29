module bus_interface(
	input iocs,
	input iorw,
	input [1:0] ioaddr,
	input rda,
	input tbr,
	inout [7:0] databus,
	input [7:0] data_in,
	output [7:0] data_out,
	output wrt_db_low,
	output wrt_db_high,
	output wrt_tx
	);

	case(ioaddr)
		2'b00 : begin
			if(iorw) begin
				databus = data_in;
				data_out = 8'h00;
				wrt_tc = 0;
			end
			else begin
				data_out = databus;
				wrt_tc = 1;
			end
			wrt_db_low = 0;
			wrt_db_high = 0;
		end
		2'b01 : begin
			databus = {6'b000000, rda, tbr};
			data_out = 8'h00;
			wrt_db_low = 0;
			wrt_db_high = 0;
			wrt_tc = 0;
		end
		2'b10 : begin
			data_out = databus;
			wrt_db_low = 1;
			wrt_db_high = 0;
			wrt_tx = 1;
		end
		2'b11 : begin
			data_out = databus;
			wrt_db_low = 0;
			wrt_db_high = 0;
			wrt_tx = 0;
		end
	endcase
endmodule