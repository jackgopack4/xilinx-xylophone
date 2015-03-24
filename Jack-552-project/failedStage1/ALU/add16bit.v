module add16bit(cout, sum, a, b, cin);

  output [15:0] sum;
  output cout;
  input cin;
  input [15:0] a, b;
  wire cout0;

  add8bit A0(cout0, sum[7:0], a[7:0], b[7:0], cin);
  add8bit A1(cout, sum[15:8], a[15:8], b[15:8], cout0);

  always@(sum) begin
//	  $display("a is %b", a);
//	  $display("b is %b", b);
//	  $display("Sum is %b", sum);
  end
endmodule
