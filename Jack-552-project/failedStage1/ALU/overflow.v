module overflow(Ov, Sign,  A_hi, B_hi, Sum_hi, Sub);

  input A_hi, B_hi, Sum_hi, Sub;
  output Ov, Sign;
  wire t0, t1;
  wire ov_add, ov_sub;

  xor3 add(.a(A_hi), .b(B_hi), .c(Sum_hi), .out(t0));
  xor3 sub(.a(A_hi), .b(!B_hi), .c(Sum_hi), .out(t1));

  assign ov_add = (t0 & !Sub)? 1'b1 : 1'b0;
  assign ov_sub = (t1 & Sub)? 1'b1 : 1'b0;
//  always@(ov_add) $display("Overflow for add is: %b", ov_add);
//  always@(ov_sub) $display("Overflow for sub is: %b", ov_sub);

  assign Ov = (ov_add | ov_sub)? 1'b1: 1'b0;
  assign Sign = (A_hi & B_hi & !Sum_hi || A_hi && !B_hi && !Sum_hi)? 1'b1: 1'b0;//(A_hi & (B_hi ^ Sub)); //Negative overflow is high

//  always@(Ov) $display("Module thinks overflow happened y/n: %b", Ov);
//  always@(Sign) $display("Sign says overflow is neg/pos: %b", Sign);
endmodule
