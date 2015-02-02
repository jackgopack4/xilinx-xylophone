`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
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
module spart(
    input clk,
    input rst,
    input iocs,
    input iorw,
    output rda,
    output tbr,
    input [1:0] ioaddr,
    inout [7:0] databus,
    output txd,
    input rxd
    );
	 
	reg [7:0] a,b;
	wire [7:0] databus_out, bus_interface_out;
	wire sel, wrt_db_low, wrt_db_high, wrt_tx, tx_rx_en;

	// Select high when writing to databus
	// reading from databus
	assign databus = sel ? a : 8'bz;
	
	always @ (posedge clk, posedge rst)
		if(rst) begin
			a <= 8'h00;
			b <= 8'h00;
		end
		else begin
			a <= databus_out;
			b <= databus;
		end		

    bus_interface bus0( .iocs(iocs),
                        .iorw(iorw),
                        .ioaddr(ioaddr),
                        .rda(rda),
                        .tbr(tbr),
                        .databus_in(b),
								.databus_out(databus_out),
                        .data_in(), // TODO: From RX
                        .data_out(bus_interface_out),
                        .wrt_db_low(wrt_db_low),
                        .wrt_db_high(wrt_db_high),
                        .wrt_tx(wrt_tx),
								.databus_sel(sel)
                        );
								
	baud_rate_gen baud0(	.clk(clk), 
								.rst(rst), 
								.en(tx_rx_en), 
								.data(bus_interface_out), 
								.sel_low(wrt_db_low), 
								.sel_high(wrt_db_high)
								);
								
module tx(
	input clk,
	input rst,
	input [7:0] data,
	input en,
	input en_tx,
	output reg tbr,
	output TxD
	);
	
module rx(
		clk,
		rst,
		RxD,
		Baud,
		RxD_data,
		RDA,
		rd_rx
		);


endmodule
