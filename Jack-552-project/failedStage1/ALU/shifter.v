module shifter(dst, src, m, shamt);

  localparam SLL = 2'b01;
  localparam SRL = 2'b10;
  localparam SRA = 2'b11;

  output [15:0] dst;
  input  [15:0] src;
  input  [1:0]  m;
  input  [3:0]  shamt;
  //always@(dst) $display("dst in shifter = %b", dst);

  wire   [15:0] shift0, shift1, shift2, shift3;
  wire   [15:0] sel0, sel1, sel2;

  assign sel0 = (shamt[0]) ? shift0 : src;
  assign sel1 = (shamt[1]) ? shift1 : sel0;
  assign sel2 = (shamt[2]) ? shift2 : sel1;
  assign dst  = (shamt[3]) ? shift3 : sel2;

  assign shift0 = (m==SLL) ? {src[14:0],1'b0}   :
	          (m==SRL) ? {1'b0,src[15:1]}   :
		             {src[15],src[15:1]};

  assign shift1 = (m==SLL) ? {sel0[13:0],2'b00}        :
	          (m==SRL) ? {2'b00,sel0[15:2]}        :
                             {sel0[15],sel0[15],sel0[15:2]};
  
  assign shift2 = (m==SLL) ? {sel1[11:0],4'h0}         :
	          (m==SRL) ? {4'h0,sel1[15:4]}         :
		             {sel1[15],sel1[15],sel1[15],sel1[15],sel1[15:4]};

  assign shift3 = (m==SLL) ? {sel2[7:0],8'h00} :
	          (m==SRL) ? {8'h00,sel2[15:8]} :
		             {sel2[15],sel2[15],sel2[15],sel2[15],sel2[15],sel2[15],sel2[15],sel2[15],sel2[15:8]};

endmodule
