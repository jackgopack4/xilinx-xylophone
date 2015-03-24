// 1-bit DFF with async reset
// Authors: John Peterson, David Hartman
// 30 SEP 2014
// ECE552
module flop1b(q, d, clk, rst_n);
  input d;
  input clk, rst_n;
  output reg q;

  always @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
      q <= 1'b0;
    end
    else begin
      q <= d;
    end
  end
endmodule
