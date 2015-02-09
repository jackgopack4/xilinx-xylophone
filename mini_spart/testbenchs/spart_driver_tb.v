
`timescale 1ns / 1ps
module spart_driver_tb();
	
    reg stm_clk, stm_rst, stm_wrt_tx, stm_rd_rx;
    reg [1:0] stm_br_cfg;
    reg [7:0] stm_tx_data;

    wire rda_mon, tbr_mon, txd_mon, rx_in, tx_en, tb_rda_mon, iocs, iorw;
	wire [1:0] ioaddr;
    wire [7:0] databus_inout, final_data_mon;

    spart spart0(	.clk(stm_clk),
    				.rst(stm_rst),
    				.iocs(iocs),
    				.iorw(iorw),
    				.rda(rda_mon),
    				.tbr(tbr_mon),
    				.ioaddr(ioaddr),
    				.databus(databus_inout),
    				.txd(txd_mon),
    				.rxd(rx_in),
				.tx_rx_en_out(tx_en)
    				);
	tx tx_tb_1(
		.clk(stm_clk),
		.rst(stm_rst),
		.data(stm_tx_data),
		.en(tx_en),
		.en_tx(stm_wrt_tx),
		.tbr(tbr_mon),
		.TxD(rx_in)
		);

	rx rx_tb_1(
		.clk(stm_clk),
		.rst(stm_rst),
		.RxD(txd_mon),
		.Baud(tx_en),
		.RxD_data(final_data_mon),
		.RDA(tb_rda_mon),
		.rd_rx(stm_rd_rx)
		);

	 driver driver0(
    		.clk(stm_clk),
    		.rst(stm_rst),
    		.br_cfg(stm_br_cfg),
    		.iocs(iocs),
    		.iorw(iorw),
    		.rda(rda_mon),
    		.tbr(tbr_mon),
    		.ioaddr(ioaddr),
    		.databus(databus_inout)
    );


always
	#5 stm_clk <= ~stm_clk;

initial begin
	stm_clk = 0;
	stm_rst = 1;
	stm_br_cfg = 2'b00;

	// TX Init
	stm_tx_data = 8'h61;
	stm_wrt_tx = 0;

	// RX Init
	stm_rd_rx = 0;
	
	// Load Low Buffer
	@(posedge stm_clk);
	stm_rst = 0;

	// Load High Buffer
	@(posedge stm_clk);

	// Send Data (Ready to Receive)
	@(posedge stm_clk);

	// Start sending spart data
	stm_wrt_tx = 1;
	@(posedge stm_clk);
	stm_wrt_tx = 0;

	@(posedge tb_rda_mon);
	repeat(100)@(posedge stm_clk);
	
	$stop();
	
end
endmodule