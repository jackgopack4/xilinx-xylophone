module sign_extenderJump(
	input [11:0] in,
	output [15:0] out);

  assign out ={{4{in[11]}}, in[11:0]}; // sign-extends

endmodule
