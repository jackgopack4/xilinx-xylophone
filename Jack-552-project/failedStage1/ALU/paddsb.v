module paddsb(Sum, A, B);

  input [15:0] A, B;
  output [15:0] Sum;

  wire cout_hi, cout_lo;
  wire [7:0] adder_out_hi, adder_out_lo;

  wire Ov_hi, Ov_lo, Sign_hi, Sign_lo;

  add8bit add_hi(cout_hi, adder_out_hi, A[15:8], B[15:8], 1'b0);
  add8bit add_lo(cout_lo, adder_out_lo, A[7:0],  B[7:0],  1'b0);

  overflow check_hi(Ov_hi, Sign_hi, A[15], B[15], add_hi[7], 1'b0);
  overflow check_lo(Ov_lo, Sign_lo, A[7],  B[7],  add_lo[7], 1'b0);

  assign Sum[15:8] = (Ov_hi) ? ((Sign_hi) ? 8'b10000000 : 8'b01111111):
	                       adder_out_hi;
  assign Sum[7:0]  = (Ov_lo) ? ((Sign_lo) ? 8'b10000000 : 8'b01111111):
	                       adder_out_lo;

endmodule
