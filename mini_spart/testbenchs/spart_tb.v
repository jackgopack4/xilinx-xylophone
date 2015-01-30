module spart_tb();
	
    reg stn_clk, stm_rst, stm_iocs, stm_iorw, stm_rxd, databus_oe;
    reg [1:0] stm_ioaddr;
    reg [7:0] databus_out;

    wire rda_mon, tbr_mon, txd_mon;
    wire [7:0] databus_inout;

    assign databus_inout = (databus_oe) ? databus_out : 6'hz;

    spart spart0(	.clk(stm_clk),
    				.rst(stm_rst),
    				.iocs(stm_iocs),
    				.iorw(stm_iorw),
    				.rda(rda_mon),
    				.tbr(tbr_mon),
    				.ioaddr(stm_ioaddr),
    				.databus(databus_inout),
    				.txd(txd_mon),
    				.rxd(stm_rxd)
    				);

endmodule