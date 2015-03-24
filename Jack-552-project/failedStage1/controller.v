module controller(OpCode, 
                  rst_n, 
                  RegDst, 
                  Branch, 
                  MemRead, 
                  MemToReg, 
                  MemWrite, 
                  ALUSrc, 
                  RegWrite, 
                  LoadHigh, 
                  JumpR, 
                  JumpAL, 
                  Halt, 
                  StoreWord);

input [3:0] OpCode; 
input rst_n;
output reg  RegDst, 
			Branch, 
			MemRead, 
			MemToReg, 
			MemWrite, 
			ALUSrc, 
			RegWrite, 	
			LoadHigh,
			StoreWord,
			JumpAL,
			JumpR,
			Halt;
			
			

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
   localparam LHB     = 4'b1010;
   localparam LLB     = 4'b1011;
   localparam B 	  = 4'b1100;
   localparam JAL 	  = 4'b1101;
   localparam JR 	  = 4'b1110;
   localparam HLT	  = 4'b1111;

// 



   always @(OpCode, rst_n) begin
   // initial
   RegDst   = 0;
   Branch   = 0;
   MemRead  = 0;
   MemToReg = 0;
   MemWrite = 0;
   ALUSrc   = 0;
   RegWrite = 0;
   LoadHigh = 0;
   StoreWord= 0;
   JumpR 	= 0;
   JumpAL 	= 0;
   Halt		= 0;
   if (~rst_n) begin
   RegDst   = 0;
   Branch   = 0;
   MemRead  = 0;
   MemToReg = 0;
   MemWrite = 0;
   ALUSrc   = 0;
   RegWrite = 0;
   LoadHigh = 0;
   StoreWord= 0;
   JumpR 	= 0;
   JumpAL 	= 0;
   Halt		= 0;
   end else
   case (OpCode)
   ADD: begin
   // R-type
   RegDst   = 1'b1;
   Branch   = 1'b0;
   MemRead  = 1'b0;
   MemToReg = 1'b0;
   MemWrite = 1'b0;
   ALUSrc   = 1'b0;
   RegWrite = 1'b1;
   LoadHigh = 0;
   
   end
   PADDSB: begin
   // R-type
   RegDst   = 1'b1;
   Branch   = 1'b0;
   MemRead  = 1'b0;
   MemToReg = 1'b0;
   MemWrite = 1'b0;
   ALUSrc   = 1'b0;
   RegWrite = 1'b1;
   LoadHigh = 0;
   
   end
   SUB: begin
   // R-type
   RegDst   = 1;
   Branch   = 0;
   MemRead  = 0;
   MemToReg = 0;
   MemWrite = 0;
   ALUSrc   = 0;
   RegWrite = 1;
   LoadHigh = 0;
   
   end
   AND: begin
   // R-type
   RegDst   = 1;
   Branch   = 0;
   MemRead  = 0;
   MemToReg = 0;
   MemWrite = 0;
   ALUSrc   = 0;
   RegWrite = 1;
   LoadHigh = 0;
   
   end
   NOR: begin
   // R-type
   RegDst   = 1;
   Branch   = 0;
   MemRead  = 0;
   MemToReg = 0;
   MemWrite = 0;
   ALUSrc   = 0;
   RegWrite = 1;
   LoadHigh = 0;
   
   end
   SLL: begin
   // R-type
   RegDst   = 1;
   Branch   = 0;
   MemRead  = 0;
   MemToReg = 0;
   MemWrite = 0;
   ALUSrc   = 0;
   RegWrite = 1;
   LoadHigh = 0;
   
   end
   SRL: begin
   // R-type
   RegDst   = 1;
   Branch   = 0;
   MemRead  = 0;
   MemToReg = 0;
   MemWrite = 0;
   ALUSrc   = 0;
   RegWrite = 1;
   LoadHigh = 0;
   
   end
   SRA: begin
   // R-type
   RegDst   = 1;
   Branch   = 0;
   MemRead  = 0;
   MemToReg = 0;
   MemWrite = 0;
   ALUSrc   = 0;
   RegWrite = 1;
   LoadHigh = 0;
   
   end
   LW: begin
   // LW-type
   RegDst   = 1;
   Branch   = 0;
   MemRead  = 1;
   MemToReg = 1;
   MemWrite = 0;
   ALUSrc   = 1;
   RegWrite = 1;
   LoadHigh = 0;
   StoreWord= 1;
   
   end
   SW: begin
   // SW-type
   RegDst   = 1;	// don't care
   Branch   = 0;
   MemRead  = 0;
   MemToReg = 0;	//don't care
   MemWrite = 1;
   ALUSrc   = 1;
   RegWrite = 0;
   LoadHigh = 0;
   StoreWord= 1;
   
   end
   LLB: begin
   // R-type
   RegDst   = 1;
   Branch   = 0;
   MemRead  = 0;
   MemToReg = 0;
   MemWrite = 0;
   ALUSrc   = 1;
   RegWrite = 1;
   LoadHigh = 0;
   
   end
   LHB: begin
   // R-type
   RegDst   = 1;
   Branch   = 0;
   MemRead  = 0;
   MemToReg = 0;
   MemWrite = 0;
   ALUSrc   = 1;
   RegWrite = 1;
   LoadHigh = 1;
   
   end
   B: begin
   // 
   RegDst   = 0;
   Branch   = 1;
   MemRead  = 0;
   MemToReg = 0;
   MemWrite = 0;
   ALUSrc   = 0;
   RegWrite = 0;
   LoadHigh = 0;
   
   end
   JAL: begin
   // 
   RegDst   = 1;
   Branch   = 0;
   MemRead  = 0;
   MemToReg = 0;
   MemWrite = 0;
   ALUSrc   = 0;
   RegWrite = 1;
   LoadHigh = 0;
   JumpAL 	= 1;
   end
   JR: begin
   // 
   RegDst   = 0;
   Branch   = 0;
   MemRead  = 0;
   MemToReg = 0;
   MemWrite = 0;
   ALUSrc   = 0;
   RegWrite = 0;
   LoadHigh = 0;
   JumpR 	= 1;
   end
   HLT: begin
   // disable all?
   RegDst   = 0;
   Branch   = 0;
   MemRead  = 0;
   MemToReg = 0;
   MemWrite = 0;
   ALUSrc   = 0;
   RegWrite = 0;
   LoadHigh = 0;
   
   Halt		= 1;
   end
   default: begin
   RegDst   = 0;
   Branch   = 0;
   MemRead  = 0;
   MemToReg = 0;
   MemWrite = 0;
   ALUSrc   = 0;
   RegWrite = 0;
   LoadHigh = 0;
   StoreWord= 0;
   JumpR 	= 0;
   JumpAL 	= 0;
   Halt 	= 0;
   end
   endcase
  end //always@


endmodule
