module cpu(clk, rst_n, hlt, pc);

/// initialize inputs/outputs ///
input clk, rst_n;
output [15:0] pc;
output hlt;


///////////////////////
// Initialize Wires //
/////////////////////

// PC //
wire [15:0] nextAddr; 
wire [15:0] programCounter, PCaddOut, PCNext;
wire [15:0] pcInc;	// to mediate between PC and nextAddr

// Instruction Memory //
wire [15:0] instruction;
wire rd_en;			 // asserted when instruction read desired

// Register Memory //
wire [15:0] readData1, readData2;
wire re0, re1;	// read enables (power not functionality)
wire [3:0] dst_addr, readReg1, readReg2;	// write address (reg)
wire [15:0] dst;	// data to be written to register file, write data (dst bus)
wire we;			// write enable

// ALU //
wire [15:0] ALUResult;
wire ov, zr, neg;
wire [3:0] shamt;
assign shamt = instruction[3:0];
wire [15:0] src2Wire;

// Branch
wire Yes;

// Sign Extension
wire [15:0] signOutALU, signOutJump, signOutBranch, signOutMem, signOutBJ;

// Flag Register
wire zrOut, negOut, ovOut, change_z, change_v, change_n;

// Data Memory //
wire [15:0] rd_data;	//output of data memory -> register write data

// Controller //
wire 	RegDst,		// 1: write back instr[11:8] to register, 0: (sw don't care) lw into register @ instr[3:0]
		Branch, 	// 1: take branch, 0: don't take branch
		MemRead, 	// 1: enable read memory, 0: disable memory read
		MemToReg, 	// 1: write data from memory to registers, 0: write data from ALU to registers
		//ALUOp, 		// Can be used to combine LW/SW with ADD, or branch instructions (we are currently not using this?)
		MemWrite,	// 1: enable memory write, 0: disable memory write
		ALUSrc, 	// 0: readData2 -> ALU 1: sign-extended -> ALU
		RegWrite,	// 1: enable right back to register, 0: don't write back to register
		PCSrc,		// 0: take next pc addr, 1: enable branch (sign-ext)
		// PCSrc is not connected to the control
		LoadHigh,	// 1: take in [11:8] as read data 1, 0: take normal read data 1
		JumpR,		// 1: if taking Jump register
		JumpAL,		// 1: if taking Jump and link
		StoreWord;	// 1: enable [11:8] -> read register for SW, 0: otherwise


/////////////////////////
// Initialize Modules //
///////////////////////

// PC //
PC pcMod(.nextAddr(nextAddr), .clk(clk), .rst(rst_n), .programCounter(programCounter));

// Program Counter
always @(posedge clk or negedge rst_n) begin
	// let's see what's going on!
	$display("programCounter=%d\n instruction#=%b\n readReg1=%d\n readReg2=%d\n readData1->ALU=%h\n src2Wire->ALU=%h\n ALUResult=%h -> dst_addrWriteReg=%d\n dst_RegWrite=%h\n readData2==dstWriteData=%h\n ALUSrc=%b\n Branch=%b, Yes=%b, PCSrc=%b\n nextAddr=%d\n negOut=%b, ovOut=%b, zrOut=%b\n signOutBranch=%d\n pcInc=%d\n signOutMem=%h", 
	      programCounter,     instruction,      readReg1,     readReg2,     readData1,          src2Wire,          ALUResult,      dst_addr,             dst,            readData2,                   ALUSrc,     Branch,    Yes,    PCSrc,     nextAddr,      negOut,   ovOut,    zrOut,    signOutBranch,     pcInc, signOutMem);
	$display("***************************\nRegDst=%b, Branch=%b, MemRead=%b, MemToReg=%b, MemWrite=%b, ALUSrc=%b, RegWrite=%b, LoadHigh=%b, JumpR=%b, JumpAL=%b StoreWord=%b\n***************************\n\n", RegDst, Branch, MemRead, MemToReg, MemWrite,
   ALUSrc, RegWrite, LoadHigh, JumpR, JumpAL, StoreWord);
	
end

// PC Adder
alu2 PCAdd(PCaddOut, pcInc, signOutBJ);
assign signOutBJ = JumpAL ? signOutJump : signOutBranch;
//assign PCNext = PCSrc ? PCaddOut : pcInc;
assign pcInc = programCounter + 1;
assign nextAddr = JumpAL ? PCaddOut : (JumpR ? readData1 : (hlt ? programCounter : (PCSrc ? PCaddOut : pcInc)));	//PCNext;

// Sign-extender
sign_extenderALU signExtenALU(instruction[7:0], signOutALU);
sign_extenderJump signExtenJUMP(instruction[11:0], signOutJump);
sign_extenderBranch signExtenBranch(instruction[8:0], signOutBranch);
sign_extenderMem signExtenMem(instruction[3:0], signOutMem);

// Branch 
branch_met BranchPred(.Yes(Yes), .ccc(instruction[11:9]), .N(negOut), .V(ovOut), .Z(zrOut), .clk(clk));
assign PCSrc = (Yes && Branch);

// Flags
flags flagReg(.zr(zrOut), .neg(negOut), .ov(ovOut), .change_z(change_z), .change_n(change_n), 
.change_v(change_v), .z_in(zr), .n_in(neg), .v_in(ov), .rst_n(rst_n), .clk(clk));

// Instruction Memory //
IM instMem(.clk(clk), .addr(programCounter), .rd_en(rd_en), .instr(instruction));
assign rd_en = 1'b1;


// Registers //
// po,p1 are 'output reg' in rfSC
rfSC registers(.clk(clk), .p0_addr(readReg1), .p1_addr(readReg2),
				.p0(readData1), .p1(readData2), .re0(re0), .re1(re1),
				.dst_addr(dst_addr), .dst(dst), .we(RegWrite), .hlt(hlt));
// Power not functionality?
assign re0 = 1'b1;
assign re1 = 1'b1;
// MUX: Write Register MUX. Changes for lw
assign dst_addr = JumpAL ? 4'b1111 : (RegDst ? instruction[11:8] : instruction[3:0]);
assign readReg1 = LoadHigh ? instruction[11:8] : instruction[7:4]; 
assign readReg2 = StoreWord ? instruction[11:8] : instruction[3:0];



// ALU //
ALU alu(.src0(readData1), .src1(src2Wire), .op(instruction[15:12]), 
.dst(ALUResult), .ov(ov), .zr(zr), .neg(neg), .shamt(shamt), .change_v(change_v),
.change_z(change_z), .change_n(change_n));
// MUX: lw/sw instruction use the sign-extended value for src1 input
assign src2Wire = StoreWord ? signOutMem : (ALUSrc ? signOutALU : readData2);



// Data Memory //
DM dataMem(.clk(clk), .addr(ALUResult), .re(MemRead), .we(MemWrite), 
		   .wrt_data(readData2), .rd_data(rd_data));
// MUX: data to be written back to registers
assign dst = JumpAL ? pcInc : (MemToReg ? rd_data : ALUResult);


// Controller //
controller ctrl(.OpCode(instruction[15:12]), .RegDst(RegDst), .Branch(Branch), 
.MemRead(MemRead), .MemToReg(MemToReg), .MemWrite(MemWrite),
.ALUSrc(ALUSrc), .RegWrite(RegWrite), .rst_n(rst_n), .LoadHigh(LoadHigh), .Halt(hlt),
.StoreWord(StoreWord), .JumpAL(JumpAL), .JumpR(JumpR));


/////////////////////////
// Pipeline SHIT      //
///////////////////////

// Instruction Memory Read //



// Register Read //



// Execute //



// Read/Write Data Memory //



// Write Back to Registers //




endmodule
