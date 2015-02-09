`timescale 1ns / 1ps
module display_pane_tb();

	reg stm_clk, stm_rst, stm_empty, stm_full;
	reg [23:0] stm_data_in;
	wire [23:0] mem_addr_mon, data_out_mon;

	display_pane dp0(
    		.clk(stm_clk),
    		.rst(stm_rst),
    		.data_in(stm_data_in),
    		.empty(stm_empty),
    		.full(stm_full),
    		.mem_addr(mem_addr_mon),
    		.data_out(data_out_mon)
    		);

	always
		#5 stm_clk <= ~stm_clk;

	initial begin
		stm_clk = 0;
		stm_rst = 1;
		stm_data_in = 24'hAABBCC;
		stm_empty = 0;
		stm_full = 0;

		@(posedge stm_clk);
		stm_rst = 0;
		// 5120
		repeat(640*8 + 8) @ (posedge stm_clk);
		stm_full = 1;
		repeat(2)@ (posedge stm_clk);
		stm_full = 0;
		
		repeat(100) @ (posedge stm_clk);
		stm_empty = 1;
		repeat(2)@(posedge stm_clk);
		stm_empty = 0;

		repeat(512) @ (posedge stm_clk);
		
		$stop();
	end
		

endmodule