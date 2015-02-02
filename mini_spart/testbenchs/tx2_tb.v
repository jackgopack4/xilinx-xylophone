module tx_tb();

reg stm_clk, stm_rst, stm_en, stm_en_tx;
reg [7:0] stm_data;

reg [4:0] i;

reg [9:0] result;

wire tbr_mon, TxD_mon;

tx tx0(
	.clk(stm_clk),
	.rst(stm_rst),
	.data(stm_data),
	.en(stm_en),
	.en_tx(stm_en_tx),
	.tbr(tbr_mon),
	.TxD(TxD_mon)
	);

always
	#5 stm_clk <= ~stm_clk;

initial begin
	stm_clk = 0;
	stm_rst = 1;
	stm_en = 0;
	stm_en_tx = 0;
	stm_data = 8'hE3;
	result = 10'h000;
	
	repeat(2) begin
		@(posedge stm_clk);
	end
	
	stm_rst = 0;
	stm_en_tx = 1;
	@(posedge stm_clk);
	stm_en_tx = 0;

	repeat(6) begin
		@(posedge stm_clk);
	end

	if(tbr_mon) begin
		$display("tbr is not set low");
		$stop();
	end

	while(~tbr_mon) begin
		result = {TxD_mon, result[9:1]};
		for(i = 0; i < 16; i = i + 1) begin
			stm_en = 1;
			@(posedge stm_clk);
			stm_en = 0;
			repeat(5) @ (posedge stm_clk);
		end
	end
	
	// result = {TxD_mon, result[9:1]};
	

	$display("Here is the end result: %h", result);
	$stop();
end
endmodule

