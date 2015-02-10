`timescale 1ns / 1ps
module vga_draw_tb();

reg stm_clk, stm_rst, stm_fifo_empty;
reg [23:0] stm_rom_color;

wire [9:0] pixel_x_mon, pixel_y_mon;
wire blank_mon, comp_sync_mon, hsync_mon, vsync_mon, read_en_mon, stm_start;
wire [7:0] pixel_r_mon, pixel_g_mon, pixel_b_mon;

vga_logic vga0(.clk(stm_clk), .rst(stm_rst), .blank(blank_mon), .comp_sync(comp_sync_mon), .hsync(hsync_mon), 
	       .vsync(vsync_mon), .pixel_x(pixel_x_mon), .pixel_y(pixel_y_mon), .start(stm_start));
    

draw_logic draw0(.clk(stm_clk), .rst(stm_rst), .pixel_x(pixel_x_mon), .pixel_y(pixel_y_mon), .pixel_r(pixel_r_mon),
		 .pixel_g(pixel_g_mon), .pixel_b(pixel_b_mon), .rom_color(stm_rom_color), .read_en_ff(read_en_mon), .fifo_empty(stm_fifo_empty));

assign fifo_re = ~stm_fifo_empty & ~blank_mon;
assign stm_start = ~stm_fifo_empty;

always 
	#5 stm_clk <= ~ stm_clk;


	initial begin
		
		stm_rst =1;
		stm_clk = 0;

		@(posedge stm_clk);
		stm_rst = 0;
		stm_fifo_empty = 1;
		stm_rom_color = 24'habcdef;

		repeat(5)@(posedge stm_clk);
		stm_fifo_empty = 0;	

		@(posedge stm_clk);

		repeat(1500)@(posedge stm_clk);
		
		$stop();
		

	end    

endmodule
