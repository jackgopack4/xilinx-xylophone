`timescale 1ns/1ps
module driver_tb();

    reg stm_clk, stm_rst, stm_rda, stm_tbr, databus_oe;
    reg [1:0] stm_br_cfg;
    reg [7:0] databus_out;

    wire iocs_mon, iorw_mon;
    wire [1:0] ioaddr_mon;
    wire [7:0] databus_inout, databus_mon;

    assign databus_inout = (databus_oe) ? databus_out : 8'hz;
    assign databus_mon = databus_inout;

	 driver driver0(	.clk(stm_clk),
						.rst(stm_rst),
						.br_cfg(stm_br_cfg),
						.iocs(iocs_mon),
						.iorw(iorw_mon),
						.rda(stm_rda),
						.tbr(stm_tbr),
						.ioaddr(ioaddr_mon),
						.databus(databus_inout)
						);

	always 
	#5 stm_clk <= ~stm_clk ;

	initial begin
		
		stm_clk = 0;
		stm_rst = 1;
		stm_rda = 0; 
		stm_tbr = 1;
		databus_oe = 0;
  		stm_br_cfg = 0;
  		databus_out = 0;

		@(posedge stm_clk);	
		stm_rst = 0;
		
		repeat(4)@(posedge stm_clk);
		databus_oe = 1;
		databus_out = 8'hFF;
		//@(posedge stm_clk);	
		stm_rda = 1;

		@(posedge stm_clk);
		databus_oe = 0;
		stm_rda = 0;

		@(posedge stm_clk);
		stm_tbr = 1;

		@(posedge stm_clk);
		stm_tbr = 0;

		repeat(4)@(posedge stm_clk);
		$stop();
		
	

	end

endmodule