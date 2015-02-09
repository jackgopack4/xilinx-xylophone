module read_rom_tb();

module rom(
	stm_clk,
	stm_rst,
	display_addr, 
	rom_data);

module display_pane(
    stm_clk,
    stm_rst,
    rom_data,
    stm_empty,
    stm_full,
    write_en_mon,
    display_addr,
    data_out_mon
    );

wire write_en_mon;
wire [23:0] rom_data, display_addr, data_out_mon;

reg stm_empty, stm_full, stm_clk, stm_rst;

always
	#5 stm_clk <= ~stm_clk;

initial begin
	stm_clk = 0;
	stm_rst = 1;
	stm_full = 0;
	stm_empty = 0;

	@(posedge clk);
	stm_rst = 0;

	repeat(512) @ (posedge stm_clk);

	$stop();

endmodule