`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:13:56 02/10/2014 
// Design Name: 
// Module Name:    vgapic 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vgapic(clk_100mhz, rst, pixel_r, pixel_g, pixel_b, hsync, vsync, blank, clk, clk_n, D, dvi_rst, scl_tri, sda_tri);

	input clk_100mhz;
	input rst;

	output hsync;
	output vsync;
	output blank;
	output dvi_rst;

	output [7:0] pixel_r;
    output [7:0] pixel_g;
    output [7:0] pixel_b;
	 
	output [11:0] D;
	 
	output clk;
	output clk_n;

	inout scl_tri, sda_tri;
	 
	wire [9:0] pixel_x;
	wire [9:0] pixel_y;
	wire [23:0] pixel_gbrg;

	assign pixel_gbrg = {pixel_g[3:0], pixel_b, pixel_r, pixel_g[7:4]};

	wire clkin_ibufg_out;
	wire clk_100mhz_buf;
	wire locked_dcm;
	 
	wire clk_25mhz;
	wire clkn_25mhz;
	wire comp_sync;

	assign clk = clk_25mhz;
	assign clk_n = ~clk_25mhz;

	wire sda_tri;
	wire scl_tri;
	wire sda;
	wire scl;

	wire [23:0] rdata;

	wire fifo_empty, fifo_full;
	wire [23:0] data_dp_fifo;
	wire [12:0] mem_addr;

	wire [23:0] fifo_data_out;
	wire fifo_wr_en, fifo_rd_en;
	reg start_display;
	
	wire fifo_re;
	
	/*/ TESTING //
	reg [9:0] pixel_count;
	wire [23:0] fifo_test;
	wire test_we;
	
	always @ (posedge clk_100mhz_buf, posedge rst)
		if(rst)
			pixel_count <= 10'h0;
		else if(pixel_count == 10'h27f)
			pixel_count <= 10'h0;
		else
			pixel_count <= pixel_count + 1;
			
	assign test_we = 1'b1;
			
	assign fifo_test = (pixel_count < 10'd319) ? 24'hff0000 : 24'h00ff00;
	///////////*/

	//DVI Interface
	assign dvi_rst = ~(rst|~locked_dcm);
	assign D = (clk)? pixel_gbrg[23:12] : pixel_gbrg[11:0];
	assign sda_tri = (sda)? 1'bz: 1'b0;
	assign scl_tri = (scl)? 1'bz: 1'b0;
	 
	dvi_ifc dvi1(.Clk(clk_25mhz),                     // Clock input
						.Reset_n(dvi_rst),       // Reset input
						.SDA(sda),                          // I2C data
						.SCL(scl),                          // I2C clock
						.Done(done),                        // I2C configuration done
						.IIC_xfer_done(iic_tx_done),        // IIC configuration done
						.init_IIC_xfer(1'b0)                // IIC configuration request
						);

	/*
	always@(posedge clk_100mhz_buf, posedge rst) begin
		if(rst) begin
			start_display <= 1'b0;
		end
		// Starting when fifo not empty, changed from waiting to be full
		else if(~fifo_empty) begin
			start_display <= 1'b1;
		end
	end
	*/
	
	assign fifo_re = blank & ~fifo_empty;
	assign vga_start = ~fifo_empty;
	
	vga_clk vga_clk_gen1 (	.CLKIN_IN(clk_100mhz), 
									.RST_IN(rst), 
									.CLKDV_OUT(clk_25mhz), 
									.CLKIN_IBUFG_OUT(clkin_ibufg_out), 
									.CLK0_OUT(clk_100mhz_buf), 
									.LOCKED_OUT(locked_dcm)
									);
	
	vga_logic vgal1(	.clk(clk_25mhz), 
							.rst(rst|~locked_dcm), 
							.blank(blank), 
							.comp_sync(comp_sync), 
							.hsync(hsync), 
							.vsync(vsync), 
							.pixel_x(pixel_x), 
							.pixel_y(pixel_y), 
							.start(vga_start)
							);	
	
	display_pane dp0(
							 .clk(clk_100mhz_buf),
							 .rst(rst),
							 .data_in(rdata),
							 .empty(fifo_empty),
							 .full(fifo_full),
							 .write_en(fifo_wr_en),
							 .mem_addr(mem_addr),
							 .data_out(data_dp_fifo)
							 );
	
	fifo_core fifo_core_gen1(	.rst(rst), // input rst
										.wr_clk(clk_100mhz_buf), // input wr_clk
										.rd_clk(clk_25mhz), // input rd_clk
										//.din(fifo_test), // TESTING
										//.wr_en(test_we), // TESTING
										.din(data_dp_fifo), // input [23 : 0] din
										.wr_en(fifo_wr_en), // input wr_en
										.rd_en(fifo_re), // input rd_en
										.dout(fifo_data_out), // output [23 : 0] dout
										.full(fifo_full), // output full
										.empty(fifo_empty) // output empty
										);
	
	draw_logic draw0(.clk(clk_25mhz), 
							.rst(rst), 
							.pixel_x(pixel_x), 
							.pixel_y(pixel_y), 
							.pixel_r(pixel_r), 
							.pixel_g(pixel_g), 
							.pixel_b(pixel_b), 
							.rom_color(fifo_data_out), 
							.fifo_empty(fifo_empty)
							);
	
	picture_rom pic_rom0(	.clka(clk_100mhz_buf), // input clka
									.rsta(rst|~locked_dcm), // input rsta
									.addra(mem_addr), // input [12 : 0] addra
									.douta(rdata) // output [23 : 0] douta
									);

endmodule
