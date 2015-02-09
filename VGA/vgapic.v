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

	wire [23:0] addr;
	wire [23:0] rdata;

	wire fifo_empty, fifo_full;
	wire [23:0] mem_addr, data_dp_fifo;

	wire [23:0] fifo_data_out;
	wire fifo_wr_en, fifo_rd_en;

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
	vga_clk vga_clk_gen1(clk_100mhz, rst, clk_25mhz, clkin_ibufg_out, clk_100mhz_buf, locked_dcm);
    vga_logic  vgal1(clk_25mhz, rst|~locked_dcm, blank, comp_sync, hsync, vsync, pixel_x, pixel_y);
	rom rom1(clk_100mhz, rst|~locked_dcm, addr, rdata);		
	display_pane dp1(clk_100mhz, rst, rdata, fifo_empty, fifo_full, mem_addr, data_dp_fifo);
	fifo_core fifo_core_gen1(rst, clk_100mhz, clk_25mhz, data_dp_fifo, fifo_wr_en, fifo_rd_en, fifo_data_out, fifo_full, fifo_empty);
	//TODO: ADD MAIN LOGIC (and draw logic)

endmodule