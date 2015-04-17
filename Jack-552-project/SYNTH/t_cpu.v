module t_cpu();
    
reg clk,rst_n;
reg [15:0] i;

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
  #5 clk = ~clk;
  
always @(posedge clk, negedge rst_n)begin
if (~rst_n) begin
i <= 0;
end else begin
i <= i + 1;
end
//$display("\n\nclk=%d%d%d%d%d%d%d%d%d%d%d%d%d\n\n", i,i,i,i,i,i,i,i,i,i,i,i,i);
if (i == 100) begin
  //$finish();
end
end
  
initial begin
  @(posedge hlt);
  @(posedge clk);
  $stop();
end    
  
endmodule
