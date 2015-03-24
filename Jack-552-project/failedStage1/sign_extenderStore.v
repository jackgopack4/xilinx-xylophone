module sign_extenderMem(in, out);
  input [3:0] in;
  output [15:0] out;
  assign out = {{12{in[3]}},in[3:0]};
endmodule
