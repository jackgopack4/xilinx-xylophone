module PC(nextAddr, clk, rst, programCounter);

input wire [15:0] nextAddr;
input clk, rst;
output reg [15:0] programCounter;

always @(posedge clk, negedge rst) begin
	if (~rst) begin
		programCounter <= 16'd0;
	end else begin
		programCounter <= nextAddr;
	end
//$display("programCounter=%d, nextAddr=%d", programCounter, nextAddr); 
end

endmodule
