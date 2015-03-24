module loadmod(Out, A, B, Sel);

  input [15:0] A, B;
  input Sel; // High is LLB, low is LHB
  output [15:0] Out;

  assign Out = (Sel)? B : // Load Low Bit
	              {B[7:0], A[7:0]}; // Load High Bit

endmodule
