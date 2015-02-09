module tx_tb();
	reg clk;
	reg rst_n;
	reg TxD_start;
	reg Enable;
	reg [7:0] TxD_data;
	wire TxD;
	wire TBR;

	tx iDUT(clk, rst_n, TxD_start, Enable, TxD_data, TxD, TBR);
	initial begin
		$dumpfile("test_tx.vcd");
		$dumpvars(0, iDUT);
		clk = 0;
		rst_n = 0;
		TxD_start = 0;
		Enable = 0;
		TxD_data = 8'b10101010;
		#12;
		rst_n = 1;
		#3;
		TxD_start = 1'b1;
		#20;
		TxD_start = 1'b0;
		#50000;
		$stop;

	end
	always begin
		#5;
		clk = ~clk;
	end
	always begin
		#25;
		Enable = 1;
		#5;
		Enable = 0;
	end
	always begin
		#475;
		$display("TxD = %b", TxD);
		$display("TBR = %b", TBR);
		#5;
	end

endmodule