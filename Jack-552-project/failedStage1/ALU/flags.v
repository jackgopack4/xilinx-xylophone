module flags(zr, neg, ov, change_z, change_n, change_v, z_in, n_in, v_in, rst_n, clk);

  input change_z, change_n, change_v;
  input z_in, n_in, v_in, rst_n, clk;
  output reg zr, neg, ov;

  always@(posedge clk) begin
    if(~rst_n) begin
	  zr <= 1'b0;
	  neg <= 1'b0;
	  ov <= 1'b0;
	end
    if(change_z == 1'b1) zr  <= z_in;
    if(change_n == 1'b1) neg <= n_in;
    if(change_v == 1'b1) ov  <= v_in;
  end

endmodule
