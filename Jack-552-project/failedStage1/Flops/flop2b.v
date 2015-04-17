// 2-bit DFF with async reset
// Authors: John Peterson, David Hartman
// 30 SEP 2014
// ECE552
module flop2b(q, d, clk, rst_n);
  input [1:0] d;
  input clk, rst_n;
  output reg [1:0] q;

  always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
      q <= 2'b0;
    end
    else begin
      q <= d;
    end
  end
endmodule
