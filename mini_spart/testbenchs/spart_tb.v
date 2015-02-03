`timescale 1ns / 1ps
module spart_tb();
	
    reg stm_clk, stm_rst, stm_iocs, stm_iorw, stm_databus_oe, stm_wrt_tx, stm_rd_rx;
    reg [1:0] stm_ioaddr;
    reg [7:0] stm_databus_in, stm_tx_data;

    wire rda_mon, tbr_mon, txd_mon, rx_in, tx_en, tb_rda_mon;
    wire [7:0] databus_inout, final_data_mon;

    assign databus_inout = (stm_databus_oe) ? stm_databus_in : 8'hzz;

    spart spart0(	.clk(stm_clk),
    				.rst(stm_rst),
    				.iocs(stm_iocs),
    				.iorw(stm_iorw),
    				.rda(rda_mon),
    				.tbr(tbr_mon),
    				.ioaddr(stm_ioaddr),
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


always
	#5 stm_clk <= ~stm_clk;

initial begin
	stm_clk = 0;
	stm_rst = 1;
	stm_iocs = 0;
	stm_iorw = 0;
	stm_databus_oe = 0;
	stm_ioaddr = 2'b00;

	// TX Init
	stm_tx_data = 8'hA5;
	stm_wrt_tx = 0;

	// RX Init
	stm_rd_rx = 0;
	
	// Load Low Buffer
	@(posedge stm_clk);
	stm_rst = 0;
	stm_iocs = 1;
	stm_ioaddr = 2'b10;
	stm_databus_oe = 1;
	stm_databus_in = 8'h80;

	// Load High Buffer
	@(posedge stm_clk);
	stm_ioaddr = 2'b11;
	stm_databus_oe = 1;
	stm_databus_in = 8'h25;

	// Send Data (Ready to Receive)
	@(posedge stm_clk);
	// Trun off bus, get ready for read
	stm_iocs = 0;
	stm_ioaddr = 2'b00;
	stm_iorw = 1;
	stm_databus_oe = 0;
	// Start sending spart data
	stm_wrt_tx = 1;
	@(posedge stm_clk);
	stm_wrt_tx = 0;

	@(posedge rda_mon)
	stm_iocs = 1;

	repeat(10) @ (posedge stm_clk);

	$display("Spart received: %h", databus_inout);

	repeat(10) @ (posedge stm_clk);
	stm_ioaddr = 2'b00;
	stm_iorw = 0;
	stm_databus_oe = 1;
	stm_databus_in = 8'hAC;

	@(posedge stm_clk);
	stm_iocs = 0;
	stm_databus_oe = 0;

	@(posedge tb_rda_mon);
	repeat(100)@(posedge stm_clk);
	
	$stop();
	
end
endmodule