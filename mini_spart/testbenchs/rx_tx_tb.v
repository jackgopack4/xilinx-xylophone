`timescale 1ns / 1ps
module tx_rx_tb();

reg stm_clk, stm_rst, stm_rd_rx, stm_en_tx, stm_low_bits, stm_high_bits;

reg[7:0] stm_data_tx, stm_baud_data;

wire RDA_mon, tbr_mon;
wire [7:0] rx_data_mon; 

wire TX_RX; 
wire baud_en;

tx tx0(
	.clk(stm_clk),
	.rst(stm_rst),
	.data(stm_data_tx),
	.en(baud_en),
	.en_tx(stm_en_tx),
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
	.rd_rx(stm_rd_rx)
	);

baud_rate_gen baud0( 
	.clk(stm_clk), 
	.rst(stm_rst), 
	.en(baud_en), 
	.data(stm_baud_data), 
	.sel_low(stm_low_bits), 
	.sel_high(stm_high_bits)
	);

always
	#5 stm_clk <= ~stm_clk;

initial begin
	stm_rst = 1;
	stm_clk = 0;
	stm_rd_rx = 0;
        stm_en_tx = 0; 
	stm_low_bits = 0; 
	stm_high_bits = 0;

	@(posedge stm_clk);
	stm_rst = 0;
	stm_low_bits = 1;
	stm_baud_data = 8'h80;

	 @(posedge stm_clk);
	stm_low_bits = 0;
	stm_high_bits = 1;
	stm_baud_data = 8'h25;

	 @(posedge stm_clk);
	stm_high_bits = 0;
	stm_data_tx = 8'hAB;
	stm_en_tx = 1;
	@(posedge stm_clk);
	stm_en_tx = 0;
	
	@(posedge RDA_mon); 
	repeat(104010)@(posedge stm_clk);
	stm_rd_rx = 1;
	@(posedge stm_clk);
	stm_rd_rx = 0;
	
	$display("We received: %h", rx_data_mon);
	$stop();
end

endmodule