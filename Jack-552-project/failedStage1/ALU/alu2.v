module alu2(Out, A, B);

  input signed [15:0] A, B;
  output signed [15:0] Out;

  assign Out = A + B;

endmodule
