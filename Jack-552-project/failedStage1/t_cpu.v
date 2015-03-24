module t_cpu();
    
reg clk,rst_n;

wire [15:0] pc;

//////////////////////
// Instantiate CPU //
////////////////////
cpu iCPU(.clk(clk), .rst_n(rst_n), .hlt(hlt), .pc(pc));

initial begin
  clk = 0;
  $display("rst assert\n");
  rst_n = 0;
  @(posedge clk);
  @(negedge clk);
  rst_n = 1;
  $display("rst deassert\n");
end 
  
always
  #1 clk = ~clk;
  
initial begin
  @(posedge hlt);
  @(posedge clk);
  $stop();
end    
  
    
/*
    reg [16:0] src0, src1;
    reg func;
    wire ov, zr, neg;
    wire [15:0] dst;

    localparam ADD = 4'b0000;
    
    /////////// Instantiate DUT ////////// 
    ALU DUT(.src0(src0[15:0]), .src1(src1[15:0]), .func(func),
           .dst(dst), .ov(ov), .zr(zr), .neg(neg));
    
   initial begin 
   // ADD 
   $display("********************ADD********************");
   #5
   func = ADD;   //4'b0000;
   src0 = 16'b0000000000000110;
   src1 = 16'b0000000000001001;
   #5  
   $display("src0=%d, src1=%d, func=%d, dst=%d", src0, src1, func, dst);  
   end 
*/   
    
endmodule
