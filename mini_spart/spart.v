`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
// Company: UW Madison 
// Engineers: Tim Zodrow, Manjot S Pal, Jack
// 
// Create Date: 2/2/2015  
// Design Name: mini-spart
// Module Name: spart
// Project Name: miniproject1
// Target Devices: FPGA
// Description: The spart is the main controller that brings all the modules together and 
// performs the intreactions between the serial input (rx) and output (tx) as well as the
// databus and signals from the driver. It connects the bus interface, tx, rx, and baud generator
// together

//////////////////////////////////////////////////////////////////////////////////////////////
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


	 
    ///////////////////////////////////
    // Interconnects between modules //
    ///////////////////////////////////
	wire [7:0] databus_out, bus_interface_out, rx_data_out;
	wire sel, wrt_db_low, wrt_db_high, wrt_tx, tx_rx_en, rd_rx;

	// Tri-state buffer used to receive and send data via the databuse
    // Sel high = output, Sel low = input
	assign databus = sel ? databus_out : 8'bzz;

    // Bus Interface Module
    bus_interface bus0( .iocs(iocs),
                        .iorw(iorw),
                        .ioaddr(ioaddr),
                        .rda(rda),
                        .tbr(tbr),
                        .databus_in(databus),
						.databus_out(databus_out),
                        .data_in(rx_data_out),
                        .data_out(bus_interface_out),
                        .wrt_db_low(wrt_db_low),
                        .wrt_db_high(wrt_db_high),
                        .wrt_tx(wrt_tx),
						.rd_rx(rd_rx),
						.databus_sel(sel)
                        );

	// Baud Rate Generator Module						
	baud_rate_gen baud0(	.clk(clk), 
							.rst(rst), 
							.en(tx_rx_en), 
							.data(bus_interface_out), 
							.sel_low(wrt_db_low), 
							.sel_high(wrt_db_high)
							);

	// TX Module (Sends data out)				
	tx tx0(	.clk(clk),
			.rst(rst),
			.data(bus_interface_out),
			.en(tx_rx_en),
			.en_tx(wrt_tx),
			.tbr(tbr),
			.TxD(txd)
			);
	
    // RX Module (Recieves data in)
	rx rx0(	.clk(clk),
			.rst(rst),
			.RxD(rxd),
			.Baud(tx_rx_en),
			.RxD_data(rx_data_out),
			.RDA(rda),
			.rd_rx(rd_rx)
	        );


endmodule
