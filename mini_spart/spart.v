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
	// output tx_rx_en_out		// Used for testing
    );
	 
	reg [7:0] a,b;
	wire [7:0] databus_out, bus_interface_out, rx_data_out;
	wire sel, wrt_db_low, wrt_db_high, wrt_tx, tx_rx_en, rd_rx;

	// Select high when writing to databus
	// reading from databus
	assign databus = sel ? databus_out : 8'bzz;
	
	//always @ (posedge clk, posedge rst)
	//	if(rst) begin
	//		a <= 8'h00;
	//		b <= 8'h00;
	//	end
	//	else begin
	//		a <= databus_out;
	//		b <= databus;
	//	end		

	// Testing //
	/////////////
	assign tx_rx_en_out = tx_rx_en;

    bus_interface bus0( .iocs(iocs),
                        .iorw(iorw),
                        .ioaddr(ioaddr),
                        .rda(rda),
                        .tbr(tbr),
                        .databus_in(databus),
								.databus_out(databus_out),
                        .data_in(rx_data_out), // TODO: From RX
                        .data_out(bus_interface_out),
                        .wrt_db_low(wrt_db_low),
                        .wrt_db_high(wrt_db_high),
                        .wrt_tx(wrt_tx),
								.rd_rx(rd_rx),
								.databus_sel(sel)
                        );
								
	baud_rate_gen baud0(	.clk(clk), 
								.rst(rst), 
								.en(tx_rx_en), 
								.data(bus_interface_out), 
								.sel_low(wrt_db_low), 
								.sel_high(wrt_db_high)
								);
								
	tx tx0(	.clk(clk),
				.rst(rst),
				.data(bus_interface_out),
				.en(tx_rx_en),
				.en_tx(wrt_tx),
				.tbr(tbr),
				.TxD(txd)
				);
	
	rx rx0(	.clk(clk),
				.rst(rst),
				.RxD(rxd),
				.Baud(tx_rx_en),
				.RxD_data(rx_data_out),
				.RDA(rda),
				.rd_rx(rd_rx)
		);


endmodule
