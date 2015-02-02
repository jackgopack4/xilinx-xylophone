module tx(
	input clk,
	input rst,
	input [7:0] data,
	intput en,
	output tbr
	);

reg [7:0] receive_buffer;

always @ (posedge clk, posedge rst)
	if(rst)
		receive_buffer <= 8'h00;
	else if (load)
		receive_buffer <= data;

always @ (*)
	