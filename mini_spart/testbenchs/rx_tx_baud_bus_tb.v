`timescale 1ns / 1ps
module tx_rx_baud_bus_tb();

reg stm_clk, stm_rst, stm_iocs, stm_iorw;
reg [1:0] stm_ioaddr;
reg[7:0] stm_databus_in;

wire RDA_mon, tbr_mon;
wire wrt_db_low, wrt_db_high, wrt_tx, rd_rx, databus_sel_mon;
wire [7:0] rx_data_mon, databus_out_mon, bus_data_out; 

wire TX_RX; 
wire baud_en;

tx tx0(
	.clk(stm_clk),
	.rst(stm_rst),
	.data(bus_data_out),
	.en(baud_en),
	.en_tx(wrt_tx),
	.tbr(tbr_mon),
	.TxD(TX_RX)
	);

rx rx0(
	 .clk(stm_clk),
	.rst(stm_rst),
	.RxD(TX_RX),
	.Baud(baud_en),
	.RxD_data(rx_data_mon),
	.RDA(RDA_mon),
	.rd_rx(rd_rx)
	);

baud_rate_gen baud0( 
	.clk(stm_clk), 
	.rst(stm_rst), 
	.en(baud_en), 
	.data(bus_data_out), 
	.sel_low(wrt_db_low), 
	.sel_high(wrt_db_high)
	);

bus_interface bus0(
	.iocs(stm_iocs),
	.iorw(stm_iorw),
	.ioaddr(stm_ioaddr),
	.rda(RDA_mon),
	.tbr(tbr_mon),
	.databus_in(stm_databus_in),
	.databus_out(databus_out_mon),
	.data_in(rx_data_mon),
	.data_out(bus_data_out),
	.wrt_db_low(wrt_db_low),
	.wrt_db_high(wrt_db_high),
	.wrt_tx(wrt_tx),
	.rd_rx(rd_rx),
	.databus_sel(databus_sel_mon)
	);

always
	#5 stm_clk <= ~stm_clk;

initial begin
	stm_rst = 1;
	stm_clk = 0;
	stm_iocs = 0;
	stm_iorw = 0;
	stm_ioaddr = 2'b00;
	stm_databus_in = 8'h00;
	

	@(posedge stm_clk);
	stm_rst = 0;
	stm_iocs = 1;
	stm_iorw = 0;
	stm_ioaddr = 2'b10;
	stm_databus_in = 8'h80;

	 @(posedge stm_clk);
	stm_ioaddr = 2'b11;
	stm_databus_in = 8'h25;

	// Write to TX (Will send to RX)
	@(posedge stm_clk);
	stm_ioaddr = 2'b00;
	stm_iorw = 0;
	stm_databus_in = 8'hA5;

	@(posedge stm_clk);
	stm_iocs = 0;

	@(posedge RDA_mon);
	stm_ioaddr = 2'b00;
	stm_iorw = 1;
	stm_iocs = 1;
	repeat(100)@(posedge stm_clk);

	
	$display("We received: %h", databus_out_mon);
	$stop();
end

endmodule