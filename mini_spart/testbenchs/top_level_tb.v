
`timescale 1ns / 1ps
module top_level_tb();
	
    reg stm_clk, stm_rst, stm_wrt_tx, stm_rd_rx, stm_sel_low, stm_sel_high;
    reg [1:0] stm_br_cfg;
    reg [7:0] stm_tx_data, stm_baud_data_in;
    reg [15:0] baud_rate_data;

    wire tbr_mon, txd_mon, rx_in, tx_rx_en, tb_rda_mon;
    wire [7:0] final_data_mon;

    reg [2:0] i;
    reg [3:0] flags;

	top_level top0(
	    .clk(stm_clk),         // 100mhz clock
	    .rst(stm_rst),         // Asynchronous reset, tied to dip switch 0
	    .txd(txd_mon),        // RS232 Transmit Data
	    .rxd(rx_in),         // RS232 Recieve Data
	    .br_cfg(stm_br_cfg) // Baud Rate Configuration, Tied to dip switches 2 and 3
	    );

	baud_rate_gen baud_tb0(
		.clk(stm_clk), 
		.rst(stm_rst), 
		.en(tx_rx_en), 
		.data(stm_baud_data_in), 
		.sel_low(stm_sel_low), 
		.sel_high(stm_sel_high)
		);

	tx tx_tb0(
		.clk(stm_clk),
		.rst(stm_rst),
		.data(stm_tx_data),
		.en(tx_rx_en),
		.en_tx(stm_wrt_tx),
		.tbr(tbr_mon),
		.TxD(rx_in)
		);

	rx rx_tb0(
		.clk(stm_clk),
		.rst(stm_rst),
		.RxD(txd_mon),
		.Baud(tx_rx_en),
		.RxD_data(final_data_mon),
		.RDA(tb_rda_mon),
		.rd_rx(stm_rd_rx)
		);

always
	case(i[1:0])
		2'b00 : baud_rate_data = 16'h12c0;
		2'b01 : baud_rate_data = 16'h2580;
		2'b10 : baud_rate_data = 16'h4b00;
		2'b11 : baud_rate_data = 16'h9600;
		default : baud_rate_data = 16'h12c0;
	endcase

always
	#5 stm_clk <= ~stm_clk;

initial begin
	for(i = 0; i < 4; i = i + 1) begin
		stm_clk = 0;
		stm_rst = 1;
		stm_br_cfg = i[1:0];

		// Baud Init
		stm_baud_data = baud_rate_data[7:0];
		stm_sel_low = 1;
		stm_sel_high = 0;

		// TX Init
		stm_tx_data = 8'h40;
		stm_wrt_tx = 0;

		// RX Init
		stm_rd_rx = 0;
		
		// Load Low Buffer
		@(posedge stm_clk);
		stm_rst = 0;

		// Load High Buffer
		@(posedge stm_clk);
		stm_sel_low = 0;
		stm_sel_high = 1;
		stm_baud_data = baud_rate_data[15:8];

		// Send Data (Ready to Receive)
		@(posedge stm_clk);
		stm_sel_high = 0;

		// Start sending spart data
		stm_wrt_tx = 1;
		@(posedge stm_clk);
		stm_wrt_tx = 0;

		@(posedge tb_rda_mon);
		@(posedge clk);

		if(final_data_mon != stm_tx_data) begin
			flags = flags & (1 << i[1:0])
		end
	end

	if(~|flags)
		$display("All tests passed!");
	else
		$display("Some tests failed, check flags: %h", flags);
	
	$stop();
	
end
endmodule