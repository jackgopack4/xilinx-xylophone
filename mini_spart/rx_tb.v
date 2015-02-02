module rx_tb();
	reg clk, rst, RxD, Baud;
	wire [7:0] RxD_data;
	wire RDA;

	rx2 iDUT(clk, rst, RxD, Baud, RxD_data, RDA);
	initial begin
		$dumpfile("test_rx.vcd");
		$dumpvars(0, iDUT);
		clk = 0;
		rst = 1;
		RxD = 1;
		Baud = 0;
		#12;
		rst = 0;
		#3;
		#20;
		RxD = 0; // Start bit
		#480;
		RxD = 1; // bit 0
		#480;
		RxD = 0; // bit 1
		#480;
		RxD = 1; // bit 2
		#480;
		RxD = 0; // bit 3
		#480;
		RxD = 1; // bit 4
		#480;
		RxD = 0; // bit 5
		#480;
		RxD = 1; // bit 6
		#480;
		RxD = 0; // bit 7
		#480;
		$display("last bit sent");
		RxD = 1; // Stop 1
		#480;
		#480; // Stop 2
		$display("second stop bit sent");
		#50000;
		$stop;

	end
	always begin
		#5;
		clk = ~clk;
	end
	always begin
		#25;
		Baud = 1;
		#5;
		Baud = 0;
	end
	always begin
		#475;
		$display("RxD_data = %b", RxD_data);
		$display("RDA = %b", RDA);
		#5;
	end

endmodule