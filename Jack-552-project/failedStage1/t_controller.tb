module t_controller();

reg [5:0] OpCode; 
wire RegDst, Branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite;					

   localparam ADD     = 4'b0000;
   localparam PADDSB  = 4'b0001;
   localparam SUB     = 4'b0010;
   localparam AND     = 4'b0011;
   localparam NOR     = 4'b0100;
   localparam SLL     = 4'b0101;
   localparam SRL     = 4'b0110;
   localparam SRA     = 4'b0111;
   localparam LW      = 4'b1000;
   localparam SW      = 4'b1001;
   localparam LLB     = 4'b1010;
   localparam LHB     = 4'b1011;

controller DUT (.OpCode(OpCode), .RegDst(RegDst), .Branch(Branch), 
.MemRead(MemRead), .MemToReg(MemToReg), .ALUOp(ALUOp), 
.MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite));

 


initial begin
$monitor("OpCode=%b, RegDst=%b, Branch=%b, MemRead=%b, MemToReg=%b, 
ALUOp=%b, MemWrite=%b, ALUSrc=%b, RegWrite=%b", OpCode, RegDst, Branch, 
MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite); 

#5
OpCode = ADD;
#5
OpCode = PADDSB;
#5
OpCode = SUB;
#5
OpCode = AND;
#5
OpCode = NOR;
#5
OpCode = SLL;
#5
OpCode = SRL;
#5
OpCode = SRA;
#5
OpCode = LW;
#5
OpCode = SW;
#5
OpCode = LLB;
#5
OpCode = LHB; 

end


endmodule
