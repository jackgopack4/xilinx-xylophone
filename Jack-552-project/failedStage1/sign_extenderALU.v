module sign_extenderALU(
	input [7:0] in,
	output [15:0] out);

  assign out = {{8{in[7]}},in[7:0]}; // sign-extends

endmodule
