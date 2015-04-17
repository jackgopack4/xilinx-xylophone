module sign_extenderBranch(
	input [8:0] in,
	output [15:0] out);

  assign out = {{7{in[8]}},in[8:0]}; // sign-extends

endmodule
