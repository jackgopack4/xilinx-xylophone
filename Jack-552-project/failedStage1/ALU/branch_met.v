module branch_met(Yes,ccc,N,V,Z,clk, op);

  input[2:0] ccc;
  input N, V, Z, clk;
  input[3:0] op;
  output reg Yes;
  localparam NEQ = 3'b000;
  localparam EQ  = 3'b001;
  localparam GT  = 3'b010;
  localparam LT  = 3'b011;
  localparam GTE = 3'b100;
  localparam LTE = 3'b101;
  localparam OV  = 3'b110;
  localparam UN  = 3'b111;

  always@(*) begin
  Yes = 0;
  if(op==4'b1100) begin
    case (ccc)
      NEQ: begin
	if(Z == 1'b0) begin
          Yes = 1;
	end
      end
      EQ: begin
	if(Z == 1'b1) begin
	  Yes = 1;
        end
      end
      GT: begin
        if(Z == 1'b0 && N == 1'b0) Yes = 1;
      end
      LT: begin
        if(N == 1'b1) Yes = 1;
      end
      GTE: begin
        if(Z == 1'b1 || (Z == 1'b0 && N == 1'b0)) Yes = 1;
      end
      LTE: begin
        if(N == 1'b1 || Z == 1'b1) Yes = 1;
      end
      OV: begin
        if(V == 1'b1) Yes = 1;
      end
      UN: begin
        Yes = 1;
      end
      default: begin
        Yes = 0;
      end
    endcase
  end
  end

endmodule
