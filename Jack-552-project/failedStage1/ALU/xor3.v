module xor3(out, a, b, c);
  input a, b, c;
  output out;
  assign out = (a && b && !c)    ? 1'b1:
	       ((!a && !b && c) ? 1'b1:
	                          1'b0);
endmodule
