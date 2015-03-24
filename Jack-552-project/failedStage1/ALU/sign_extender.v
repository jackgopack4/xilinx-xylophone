module sign_extender (
	input signed [7:0] in,
	output signed [15:0] out);

  assign out = in; // sign-extends

endmodule
