`timescale 1ns/1ps
module baud_rate_gen_tb();


reg stm_clk, stm_rst, stm_sel_low, stm_sel_high;
reg [7:0] data;

wire en_mon;

baud_rate_gen baud0( .clk(stm_clk), .rst(stm_rst), .sel_low(stm_sel_low), .sel_high(stm_sel_high), .data(data),
			 .en(en_mon));

always begin
	#5 stm_clk <= ~stm_clk;
end

initial begin
		
	stm_rst =1;
	stm_clk=0;
	stm_sel_low = 0;
	stm_sel_high = 0;
	data = 0;
	
	@(posedge stm_clk);
	stm_rst = 0;
	stm_sel_low = 1;
	data = 8'hc0;
	
	@(posedge stm_clk);
	stm_sel_low = 0;
	stm_sel_high = 1;
	data = 8'h12;
	
	@(posedge stm_clk);
	stm_sel_high = 0;

	repeat(16)@(posedge en_mon);

	$stop();

	end
endmodule
