module fifo_core_tb();

reg stm_rst, stm_wr_clk, stm_rd_clk;
reg [23 : 0] stm_din;
reg stm_wr_en;
reg stm_rd_en;
wire [23 : 0] dout_mon;
wire full_mon;
wire empty_mon;

module fifo_core(
  .rst(stm_rst),
  .wr_clk(stm_wr_clk),
  .rd_clk(stm_rd_clk,
  .din(stm_din),
  .wr_en(stm_wr_en),
  .rd_en(stm_rd_en),
  .dout(dout_mon),
  .full(full_mon),
  .empty(empty_mon)
);

always
	#5 stm_wr_clk <= ~stm_wr_clk;

always
	#20 stm_rd_clk <= ~stm_rd_clk;

initial begin
	stm_rd_clk = 0;
	stm_wr_clk = 0;
	stm_din = 24'h123456;
	stm_rst = 1;
	stm_rd_en = 0;
	stm_wr_en = 0;

	@(posedge stm_wr_clk);

	stm_wr_en = 1;

	@(posedge stm_wr_clk);

	stm_din = 24'h89abcd;

	@(posedge stm_wr_clk);

	stm_din = 24'h342165;

	@(posedge stm_wr_clk);

	stm_wr_en = 0;

	@(posedge stm_rd_clk);

	stm_rd_en = 1;

	repeat(5)@(posedge stm_rd_clk);

	$stop();


end

endmodule