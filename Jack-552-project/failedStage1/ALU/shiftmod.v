module shiftmod(Out, Z, A, Op, Shamt);

  input [15:0] A;
  input [1:0] Op;
  input [3:0] Shamt;

  output [15:0] Out;
  output Z;

  shifter shift_it(Out, A, Op, Shamt);
  assign Z = (A == 16'h0000)? 1'b1: 1'b0;

endmodule
