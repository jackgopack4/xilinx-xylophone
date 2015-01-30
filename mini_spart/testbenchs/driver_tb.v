module driver_tb();

    reg stm_clk, stm_rst, stm_rda, stm_tbr, databus_oe;
    reg [1:0] stm_br_cfg;
    reg [7:0] databus_out;

    wire iocs_mon, iorw_mon;
    wire [1:0] ioaddr_mon;
    wire [7:0] databus_inout;

    assign databus_inout = (databus_oe) ? databus_out : 8'hz;

	module driver driver0(	.clk(stm_clk),
						.rst(stm_rst),
						.br_cfg(stm_br_cfg),
						.iocs(iocs_mon),
						.iorw(iorw_mon),
						.rda(stm_rda),
						.tbr(stm_tbr),
						.ioaddr(ioaddr_mon),
						.databus(databus_inout)
						);

endmodule