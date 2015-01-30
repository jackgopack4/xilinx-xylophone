module bus_interface_tb();


wire stm_wrt_db_low, stm_wrt_db_high, stm_wrt_tx, stm_databus_sel;
wire [7:0] stm_data_out, stm_databus_out;

reg stm_iocs, stm_iorw, stm_rda, stm_tbr;
reg [1:0] stm_ioaddr;
reg [7:0] stm_databus_in, stm_data_in;

bus_interface bus0( .iocs(stm_iocs), .iorw(stm_iorw), .ioaddr(stm_ioaddr), .rda(stm_rda), .tbr(stm_tbr), .databus_in(stm_databus_in), .databus_out(stm_databus_out), 
		    .data_in(stm_data_in), .data_out(stm_data_out), .wrt_db_low(stm_wrt_db_low), .wrt_db_high(stm_wrt_db_high), .wrt_tx(stm_wrt_tx), .databus_sel(stm_databus_sel));

initial begin

	stm_iocs = 0;
	stm_iorw = 0;
	stm_rda = 1;
	stm_tbr = 1;
	stm_ioaddr = 0;
	stm_databus_in = 8'hBB;
	stm_data_in = 8'hAA;

	#5 
	stm_iocs = 1;
	stm_iorw = 1;

	#1;
	if(stm_databus_out != 8'hAA) begin
		$display("databus_out was incorrect");
		$stop();
	end
	
	#5
	stm_iorw = 0;

	#5
	stm_iorw = 1;
	stm_ioaddr = 1;

	#5
	stm_ioaddr = 2'b10;
	
	#5
	stm_ioaddr = 2'b11;

	#5
	$display("Well done!");
	$stop();


	end
endmodule