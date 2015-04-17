module cpu(clk, rst_n, hlt, pc);

////////////////////////////////
// initialize inputs/outputs //
//////////////////////////////
input clk, rst_n;
output [15:0] pc;
output hlt;

///////////////////////
// Initialize Wires //
/////////////////////

// PC //
wire [15:0] nextAddr;
wire [15:0] programCounter, PCaddOut, PCNext;
wire [15:0] pcInc;            // to mediate between PC and nextAddr

// Instruction Memory //
wire [15:0] instruction;
wire rd_en;                     // asserted when instruction read desired

// Register Memory //
wire [15:0] readData1, readData2;
wire re0, re1;                // read enables (power not functionality)
wire [3:0] dst_addr, readReg1, readReg2;    // write address (reg)
wire [15:0] dst;            // data to be written to register file, write data (dst bus)
wire we;                    // write enable

// ALU //
wire [15:0] ALUResult;
wire ov, zr, neg;
wire [3:0] shamt;
assign shamt = instruction[3:0];
wire [15:0] src2Wire, ALU1, ALU2;

// Branch
wire Yes;                    // Yes is 1 if branch condition is satisfied

// Sign Extension
wire [15:0] signOutALU, signOutJump, signOutBranch, signOutMem, signOutBJ;

// Flag Register
wire zrOut, negOut, ovOut, change_z, change_v, change_n;

// Data Memory //
wire [15:0] rd_data;        //output of data memory -> register write data

// Controller //
wire     RegDst,        // 1: write back instr[11:8] to register, 0: (sw don't care) lw into register @ instr[3:0]
        Branch,     // 1: take branch, 0: don't take branch
        MemRead,     // 1: enable read memory, 0: disable memory read
        MemToReg,     // 1: write data from memory to registers, 0: write data from ALU to registers
        MemWrite,    // 1: enable memory write, 0: disable memory write
        ALUSrc,     // 0: readData2 -> ALU 1: sign-extended -> ALU
        RegWrite,    // 1: enable right back to register, 0: don't write back to register
        PCSrc,        // 0: take next pc addr, 1: enable branch (sign-ext)
        LoadHigh,    // 1: take in [11:8] as read data 1, 0: take normal read data 1
        JumpR,        // 1: if taking Jump register
        JumpAL,        // 1: if taking Jump and link
        StoreWord;    // 1: enable [11:8] -> read register for SW, 0: otherwise

// Pipe Line //
  // IF/ID block wires
  wire [15:0] EX_pcInc_IF_ID;
  wire [15:0] instr_IF_ID;
  wire [15:0] DM_programCounter_IF_ID;
  wire [15:0] DM_pcInc_IF_ID;
  wire [15:0] instruction_To_IF_ID;
  wire [15:0] pcInc_To_IF_ID;
  wire WB_hlt_IF_ID;


  // ID/EX Block wires
  wire EX_ALUSrc_ID_EX, DM_Branch_ID_EX, DM_MemRead_ID_EX, DM_MemWrite_ID_EX;
  wire DM_JumpR_ID_EX, DM_JumpAL_ID_EX, DM_MemToReg_ID_EX, WB_RegWrite_ID_EX, EX_StoreWord_ID_EX;
  wire DM_RegDst_ID_EX;
  wire [15:0] EX_signOutBranch_ID_EX, EX_signOutALU_ID_EX, EX_signOutMem_ID_EX, EX_signOutJump_ID_EX;
  wire [3:0] EX_shamt_ID_EX, EX_opCode_ID_EX, DM_ccc_ID_EX, WB_dst_addr_ID_EX, EX_Rs_Addr_ID_EX, EX_Rt_Addr_ID_EX;
  wire [15:0] EX_readData1_ID_EX, DM_readData2_ID_EX, DM_pcInc_ID_EX, DM_programCounter_ID_EX;
  wire [15:0] instr_ID_EX;
  wire WB_hlt_ID_EX;

  // EX/DM block wires
  wire DM_Branch_EX_DM, DM_MemRead_EX_DM, DM_MemWrite_EX_DM;
  wire DM_JumpR_EX_DM, DM_JumpAL_EX_DM;
  wire DM_MemToReg_EX_DM, DM_zrOut_EX_DM, DM_negOut_EX_DM, DM_ovOut_EX_DM, WB_RegWrite_EX_DM;
  wire DM_RegDst_EX_DM;
  wire [15:0] EX_readData1_EX_DM, DM_readData2_EX_DM, DM_ALUResult_EX_DM, DM_pcInc_EX_DM;
  wire [15:0] DM_programCounter_EX_DM, DM_PCaddOut_EX_DM;
  wire [3:0] DM_ccc_EX_DM, WB_dst_addr_EX_DM;
  wire [15:0] instr_EX_DM;
  wire WB_hlt_EX_DM;

  // DM/WB block wires
  wire WB_RegWrite_DM_WB;
  wire [3:0] WB_dst_addr_DM_WB;
  wire [15:0] WB_dst_DM_WB;

// Forwarding //
wire [1:0] forwardA, forwardB;

// Hazard Detection //
wire stall, StoreWord_To_ID_EX, JumpAL_To_ID_EX, ALUSrc_To_ID_EX, Branch_To_ID_EX, MemRead_To_ID_EX,
MemWrite_To_ID_EX, JumpR_To_ID_EX, MemToReg_To_ID_EX, RegWrite_To_ID_EX;

/////////////////////////
// Initialize Modules //
///////////////////////

////////////************ Display ************//////////////
always @(posedge clk) begin
    // let's see what's going on!
    //$display("programCounter=%d\n instruction#=%b\n readReg1=%d\n readReg2=%d\n readData1->ALU=%h\n src2Wire->ALU=%h\n ALUResult=%h -> dst_addrWriteReg=%d\n dst_RegWrite=%h\n readData2==dstWriteData=%h\n ALUSrc=%b\n Branch=%b, Yes=%b, PCSrc=%b\n nextAddr=%d\n negOut=%b, ovOut=%b, zrOut=%b\n signOutBranch=%d\n pcInc=%d\n signOutMem=%h",
    //      programCounter,     instruction,      readReg1,     readReg2,     readData1,          src2Wire,          ALUResult,      dst_addr,             dst,            readData2,                   ALUSrc,     Branch,    Yes,    PCSrc,     nextAddr,      negOut,   ovOut,    zrOut,    signOutBranch,     pcInc, signOutMem);
    //$display("***************************\nRegDst=%b, Branch=%b, MemRead=%b, MemToReg=%b, MemWrite=%b, ALUSrc=%b, RegWrite=%b, LoadHigh=%b, JumpR=%b, JumpAL=%b StoreWord=%b\n***************************\n\n", RegDst, Branch, MemRead, MemToReg, MemWrite,
  // ALUSrc, RegWrite, LoadHigh, JumpR, JumpAL, StoreWord);
  $display("\n********** IF Stage **********");
  $display("programCounter=%h pcInc=%h nextAddr=%h\ninstruction=%h",
            programCounter,     pcInc,     nextAddr,     instruction);
  $display("nextAddr =  DM_JumpAL_EX_DM=%b ? DM_PCaddOut_EX_DM=%h :\n(DM_JumpR_EX_DM=%b  ? EX_readData1_EX_DM=%h :\n(WB_hlt_EX_DM=%b   ? DM_programCounter_EX_DM=%h :\n(PCSrc=%b           ? DM_PCaddOut_EX_DM=%h :\npcInc=%b)));",
                        DM_JumpAL_EX_DM,     DM_PCaddOut_EX_DM,       DM_JumpR_EX_DM,      EX_readData1_EX_DM,       WB_hlt_EX_DM,       DM_programCounter_EX_DM,       PCSrc,               DM_PCaddOut_EX_DM,      pcInc);
  $display("********** ID Stage **********");
  $display("programCounter=%h instruction=%h\nreadReg1=%d readReg2=%d\nreadData1=%h readData2=%h",
            DM_programCounter_IF_ID, instr_IF_ID, readReg1, readReg2, readData1, readData2);
  /*$display("signOutALU=%h signOutMem=%h signOutBranch=%h signOutJump=%h",
            signOutALU,   signOutMem,   signOutBranch,   signOutJump);
*/
  $display("********** EX Stage **********");
  $display("programCounter=%h\nALUSrc1=%h ALUSrc2=%h\nOpCode=%b ALUResult=%h\nneg=%b ov=%b zr=%b",
            DM_programCounter_ID_EX, ALU1, ALU2, EX_opCode_ID_EX, ALUResult, negOut, ovOut, zrOut);
  $display("forwardA=%b forwardB=%b",forwardA, forwardB);
  $display("ALU1 = (forwardA == 2'b10) ? DM_ALUResult_EX_DM=%h : ((forwardA == 2'b01) ? WB_dst_DM_WB=%h : EX_readData1_ID_EX=%h);",
                                         DM_ALUResult_EX_DM,                            WB_dst_DM_WB,     EX_readData1_ID_EX);
  $display("ALU2 = (forwardB == 2'b10) ? DM_ALUResult_EX_DM=%h : ((forwardB == 2'b01) ? WB_dst_DM_WB=%h : src2Wire=%h);",
                                         DM_ALUResult_EX_DM,                            WB_dst_DM_WB,     src2Wire);
  $display("signOutALU=%h signOutMem=%h signOutBranch=%h signOutJump=%h",
            EX_signOutALU_ID_EX,   EX_signOutMem_ID_EX,   EX_signOutBranch_ID_EX,   EX_signOutJump_ID_EX);
  $display("alu2out=PCaddOut=%h DM_pcInc_ID_EX=%h signOutBJ=%h \nDM_JumpAL_ID_EX=%b EX_signOutBranch_ID_EX=%h EX_signOutJump_ID_EX=%h",
            PCaddOut,           DM_pcInc_ID_EX,   signOutBJ,     DM_JumpAL_ID_EX,   EX_signOutBranch_ID_EX,   EX_signOutJump_ID_EX);
  $display("********** DM Stage **********");
  $display("programCounter=%h\nmemAddr=%h memWrtData=%h\nMemRead=%b MemWrite=%b\nrd_data=%h\nccc=%b Yes=%b Branch=%b",
            DM_programCounter_EX_DM, DM_ALUResult_EX_DM, DM_readData2_EX_DM, DM_MemRead_EX_DM, DM_MemWrite_EX_DM, rd_data, DM_ccc_EX_DM, Yes, DM_Branch_EX_DM);
    $display("dst_addr=%h = DM_JumpAL_EX_DM=%b ? 4'b1111 : (DM_RegDst_EX_DM=%b ? instr_EX_DM[11:8]=%b : instr_EX_DM[3:0]=%b);",
              dst_addr,     DM_JumpAL_EX_DM,            DM_RegDst_EX_DM,     instr_EX_DM[11:8],     instr_EX_DM[3:0]);
    $display("dst=%h = DM_JumpAL_EX_DM=%b   ? DM_pcInc_EX_DM=%h :\n(DM_MemToReg_EX_DM=%b ? rd_data=%h :\nDM_ALUResult_EX_DM=%h);",
              dst,     DM_JumpAL_EX_DM,       DM_pcInc_EX_DM,       DM_MemToReg_EX_DM,     rd_data,      DM_ALUResult_EX_DM);
  $display("********** nextAddr immediate assign **********");
  $display("nextAddr=%h\nJumpAL=%b JumpR=%b hlt=%b PCSrc=%b",
            nextAddr,     DM_JumpAL_EX_DM, DM_JumpR_EX_DM, WB_hlt_EX_DM, PCSrc);
  /*$display(       "DM_JumpAL_EX_DM=%b ? DM_PCaddOut_EX_DM      =%h :\nDM_JumpR_EX_DM =%b ? DM_readData1_EX_DM     =%h :\nWB_hlt_EX_DM  =%b ? DM_programCounter_EX_DM=%h :\nPCSrc          =%b ? DM_PCaddOut_EX_DM      =%h :\n                    pcInc                  =%h",
                   DM_JumpAL_EX_DM,     DM_PCaddOut_EX_DM,
                   DM_JumpR_EX_DM,      DM_readData1_EX_DM,
                   WB_hlt_EX_DM,       DM_programCounter_EX_DM,
                   PCSrc,               DM_PCaddOut_EX_DM,
                                        pcInc);
*/
  $display("********** WB Stage **********");
  $display("regWriteAddr=%d regWriteData=%h RegWrite=%b\n\n\n",
           WB_dst_addr_DM_WB , WB_dst_DM_WB, WB_RegWrite_DM_WB);

end


////////////************ PC ************//////////////
PC pcMod(.nextAddr(nextAddr),
        .clk(clk),
        .rst(rst_n),
        .programCounter(programCounter));
assign pcInc = programCounter + 1;
assign programCounterDec = programCounter - 1;


////////////************ Instruction Memory - IF ************//////////////
IM instMem(.clk(clk),
           .addr(programCounter),
           .rd_en(rd_en),
           .instr(instruction));
assign rd_en = 1'b1;


////////////************ Registers - ID ************//////////////
rf   registers(.clk(clk),
               .p0_addr(readReg1),
               .p1_addr(readReg2),
               .p0(readData1),
               .p1(readData2),
               .re0(re0),
               .re1(re1),
               .dst_addr(WB_dst_addr_DM_WB),
               .dst(WB_dst_DM_WB),
               .we(WB_RegWrite_DM_WB),
               .hlt(hlt));
// Power not functionality
assign re0 = 1'b1;
assign re1 = 1'b1;
// MUX for choosing which registers addr to load from register memory
assign readReg1 = LoadHigh ? instr_IF_ID[11:8] : instr_IF_ID[7:4];
assign readReg2 = StoreWord ? instr_IF_ID[11:8] : instr_IF_ID[3:0];
// MUX for write register addr. JumpAL stores in R13, RegDst controls addr
assign dst_addr = JumpAL ? 4'b1111 : (RegDst ? instr_IF_ID[11:8] : instr_IF_ID[3:0]);
// Sign-extenders
sign_extenderALU signExtenALU(instr_IF_ID[7:0], signOutALU);
sign_extenderJump signExtenJUMP(instr_IF_ID[11:0], signOutJump);
sign_extenderBranch signExtenBranch(instr_IF_ID[8:0], signOutBranch);
sign_extenderMem signExtenMem(instr_IF_ID[3:0], signOutMem);



////////////************ ALU - EX ************//////////////
ALU alu(.src0(ALU1),
        .src1(ALU2),
        .op(EX_opCode_ID_EX),
        .dst(ALUResult),
        .ov(ov),
        .zr(zr),
        .neg(neg),
        .shamt(EX_shamt_ID_EX),
        .change_v(change_v),
        .change_z(change_z),
        .change_n(change_n));
// MUX: lw/sw instruction use the sign-extended value for src1 input
assign src2Wire = EX_StoreWord_ID_EX ? EX_signOutMem_ID_EX :
                 (EX_ALUSrc_ID_EX    ? EX_signOutALU_ID_EX :
                                       DM_readData2_ID_EX);
// Adds Branch/Jump signed address to pcInc +1
alu2 PCAdd(PCaddOut, DM_pcInc_ID_EX, signOutBJ);
// Mux to choose which signed address to add to pcInc
assign signOutBJ = DM_JumpAL_ID_EX ? EX_signOutJump_ID_EX : EX_signOutBranch_ID_EX;
// Flags (should reflect for the next cycle
flags flagReg(.zr(zrOut), .neg(negOut), .ov(ovOut), .change_z(change_z), .change_n(change_n),
.change_v(change_v), .z_in(zr), .n_in(neg), .v_in(ov), .rst_n(rst_n), .clk(clk));
// forwarding
assign ALU1 = (forwardA == 2'b10) ? DM_ALUResult_EX_DM : ((forwardA == 2'b01) ? WB_dst_DM_WB : EX_readData1_ID_EX);
assign ALU2 = (forwardB == 2'b10) ? DM_ALUResult_EX_DM : ((forwardB == 2'b01) ? WB_dst_DM_WB : src2Wire);



////////////************ Data Memory - MEM ************//////////////
DM dataMem(.clk(clk),
           .addr(DM_ALUResult_EX_DM),
           .re(DM_MemRead_EX_DM),
           .we(DM_MemWrite_EX_DM),
           .wrt_data(DM_readData2_EX_DM),
           .rd_data(rd_data));
// MUX: data to be written back to registers. If JumpAL, store pc +1, otherwise store ALUResult or mem
assign dst = DM_JumpAL_EX_DM   ? DM_pcInc_EX_DM :
            (DM_MemToReg_EX_DM ? rd_data :
                                 DM_ALUResult_EX_DM);
// Mux to choose what next addr should be. Chooses between branch, jump, jump and link, halt,  or PCSrc
assign nextAddr =  DM_JumpAL_EX_DM ? DM_PCaddOut_EX_DM :
                  (DM_JumpR_EX_DM  ? EX_readData1_EX_DM :
                  (PCSrc           ? DM_PCaddOut_EX_DM :
                                     pcInc));    //PCNext;
// Branch
branch_met BranchPred(.Yes(Yes),
                      .ccc(DM_ccc_ID_EX[2:0]),
                      .N(DM_negOut_EX_DM),
                      .V(DM_ovOut_EX_DM),
                      .Z(DM_zrOut_EX_DM),
                      .clk(clk),
                      .op(instr_ID_EX[15:12])
                      );
//Take conditional branch if condition is met (Yes) and it is a branch instruction
assign PCSrc = (Yes && DM_Branch_EX_DM);


////////////************ Write Back - WB ************//////////////




/////////////////////////
// Pipeline SHIT      //
///////////////////////

// **************************************************************************************
//TODO: need to pass through Branch, ALUOp, ALUSrc, PCSrc still.
//        follow MemToReg as a reference
//TODO: also need to connect the block outputs to the correct modules above
// **************************************************************************************

  ////**** d -> [FLOP] -> q ****////

  // IF/ID BLOCK
  flop16b ID_flop(.q(instr_IF_ID), .d(instruction_To_IF_ID), .clk(clk), .rst_n(rst_n));
  flop16b f16_EX_pcInc_IF_ID(DM_pcInc_IF_ID, pcInc_To_IF_ID, clk, rst_n);
  flop16b f16_DM_programCounter_IF_ID(DM_programCounter_IF_ID, programCounter , clk, rst_n);    // Program Counter
  // Stall MUX to flush out instruction and pcInc
  assign instruction_To_IF_ID = (stall || PCSrc) ? 16'h0000 : instruction;
  assign pcInc_To_IF_ID = (stall || PCSrc) ? 16'h0000 : pcInc;

  // NEW Controller //
   controller ctrl(.OpCode(instr_IF_ID[15:12]), // ID
                   .RegDst(RegDst),             // ID
                   .LoadHigh(LoadHigh),         // ID
                   .StoreWord(StoreWord),         // ID
                   .JumpAL(JumpAL),             // EX
                   .ALUSrc(ALUSrc),                // EX
                   .Branch(Branch),             // DM
                   .MemRead(MemRead),             // DM
                   .MemWrite(MemWrite),            // DM
                   .Halt(WB_hlt_IF_ID),                    // DM
                   .JumpR(JumpR),                // DM
                   .MemToReg(MemToReg),         // WB
                   .RegWrite(RegWrite),         // WB
                   .rst_n(rst_n));

// Stall MUX to flush out pipeline flops
assign StoreWord_To_ID_EX = (stall || PCSrc) ? 1'b0 : StoreWord;
assign JumpAL_To_ID_EX = (stall || PCSrc) ? 1'b0 : JumpAL;
assign ALUSrc_To_ID_EX = (stall || PCSrc) ? 1'b0 : ALUSrc;
assign Branch_To_ID_EX = (stall || PCSrc) ? 1'b0 : Branch;
assign MemRead_To_ID_EX = (stall || PCSrc) ? 1'b0 : MemRead;
assign MemWrite_To_ID_EX = (stall || PCSrc) ? 1'b0 : MemWrite;
assign JumpR_To_ID_EX = (stall || PCSrc) ? 1'b0 : JumpR;
assign MemToReg_To_ID_EX = (stall || PCSrc) ? 1'b0 : MemToReg;
assign RegWrite_To_ID_EX = (stall || PCSrc) ? 1'b0 : RegWrite;

  // Example Format:
  //     Destination_Signal_From_To(Output, Input, clk, rst_n);

  // ID/EX BLOCK //
  flop1b f1_EX_ALUSrc_ID_EX(EX_ALUSrc_ID_EX, ALUSrc_To_ID_EX, clk, rst_n);// ALUSrc
  flop16b f16_EX_signOutBranch_ID_EX(EX_signOutBranch_ID_EX, signOutBranch, clk, rst_n);    // signOutBranch
  flop16b f16_EX_signOutALU_ID_EX(EX_signOutALU_ID_EX, signOutALU, clk, rst_n);    // signOutALU
  flop16b f16_EX_signOutMem_ID_EX(EX_signOutMem_ID_EX, signOutMem, clk, rst_n);    // signOutMem
  flop16b f16_EX_signOutJump_ID_EX(EX_signOutJump_ID_EX, signOutJump, clk, rst_n); // signOutJump
  flop4b f4_EX_shamt_ID_EX(EX_shamt_ID_EX, instr_IF_ID[3:0], clk, rst_n);    // shamt
  flop16b f16_EX_readData1_ID_EX(EX_readData1_ID_EX, readData1, clk, rst_n);// readData1
  flop16b f16_DM_readData2_ID_EX(DM_readData2_ID_EX, readData2, clk, rst_n); // readData2
  flop4b f4_EX_opCode_ID_EX(EX_opCode_ID_EX, instr_IF_ID[15:12], clk, rst_n);    //opCode
  flop1b f1_DM_Branch_ID_EX(DM_Branch_ID_EX, Branch_To_ID_EX, clk, rst_n); // Branch
  flop1b f1_EX_StoreWord_ID_EX(EX_StoreWord_ID_EX, StoreWord_To_ID_EX, clk, rst_n); // StoreWord
  flop1b f1_DM_MemRead_ID_EX(DM_MemRead_ID_EX, MemRead_To_ID_EX, clk, rst_n); // MemRead
  flop1b f1_DM_MemWrite_ID_EX(DM_MemWrite_ID_EX, MemWrite_To_ID_EX, clk, rst_n);    // MemWrite
  flop1b f1_DM_JumpR_ID_EX(DM_JumpR_ID_EX, JumpR_To_ID_EX, clk, rst_n); // JumpR
  flop1b f1_DM_JumpAL_ID_EX(DM_JumpAL_ID_EX, JumpAL_To_ID_EX, clk, rst_n);  // JumpAL
  flop1b f1_DM_MemToReg(DM_MemToReg_ID_EX, MemToReg_To_ID_EX, clk, rst_n);    // MemToReg
  flop1b f1_DM_RegDst_ID_EX(DM_RegDst_ID_EX, RegDst, clk, rst_n);
  flop16b f16_DM_pcInc_ID_EX(DM_pcInc_ID_EX, DM_pcInc_IF_ID, clk, rst_n);    //pcInc
  flop16b f16_DM_programCounter_ID_EX(DM_programCounter_ID_EX, DM_programCounter_IF_ID, clk, rst_n);    // Program Counter
  flop4b f4_DM_ccc_ID_EX(DM_ccc_ID_EX, {1'b0, instr_IF_ID[11:9]}, clk, rst_n);    // ccc
  flop1b f1_WB_RegWrite_ID_EX(WB_RegWrite_ID_EX, RegWrite_To_ID_EX, clk, rst_n);        // RegWrite
  // Forwarding registers addr
  flop4b f4_EX_Rs_Addr_ID_EX(EX_Rs_Addr_ID_EX, readReg1, clk, rst_n);    // instr_IF_ID[7:4]??
  flop4b f4_EX_Rt_Addr_ID_EX(EX_Rt_Addr_ID_EX, readReg2, clk, rst_n);
  flop4b f4_WB_dst_addr_ID_EX(WB_dst_addr_ID_EX, dst_addr, clk, rst_n); // dst_addr
  flop16b f16_instr_ID_EX(instr_ID_EX, instr_IF_ID, clk, rst_n);
  flop1b f1_WB_hlt_ID_EX(WB_hlt_ID_EX, WB_hlt_IF_ID, clk, rst_n);

  // EX/DM BLOCK //
  flop1b f1_DM_Branch_EX_DM(DM_Branch_EX_DM, DM_Branch_ID_EX, clk, rst_n); // Branch
  flop1b f1_DM_MemRead_EX_DM(DM_MemRead_EX_DM, DM_MemRead_ID_EX, clk, rst_n);    // MemRead
  flop1b f1_DM_MemWrite_EX_DM(DM_MemWrite_EX_DM, DM_MemWrite_ID_EX, clk, rst_n);    // MemWrite
  flop1b f1_DM_JumpR_EX_DM(DM_JumpR_EX_DM, DM_JumpR_ID_EX, clk, rst_n); // JumpR
  flop1b f1_DM_JumpAL_EX_DM(DM_JumpAL_EX_DM, DM_JumpAL_ID_EX, clk, rst_n); // JumpAL
  flop1b f1_DM_MemToReg_EX_DM(DM_MemToReg_EX_DM, DM_MemToReg_ID_EX, clk, rst_n); // MemToReg
  flop16b f16_EX_readData1_EX_DM(EX_readData1_EX_DM, EX_readData1_ID_EX, clk, rst_n);
  flop16b f16_DM_readData2_EX_DM(DM_readData2_EX_DM, DM_readData2_ID_EX, clk, rst_n); // readData2

  flop16b f16_DM_ALUResult_EX_DM(DM_ALUResult_EX_DM, ALUResult, clk, rst_n);
  flop16b f16_DM_programCounter_EX_DM(DM_programCounter_EX_DM, DM_programCounter_ID_EX, clk, rst_n);
  flop16b f16_DM_pcInc_EX_DM(DM_pcInc_EX_DM, DM_pcInc_ID_EX, clk, rst_n);
  flop16b f16_DM_PCaddOut_EX_DM(DM_PCaddOut_EX_DM, PCaddOut, clk, rst_n);
  flop1b f1_DM_RegDst_EX_DM(DM_RegDst_EX_DM, DM_RegDst_ID_EX, clk, rst_n);
  flop1b f1_DM_zrOut_EX_DM(DM_zrOut_EX_DM, zrOut, clk, rst_n);
  flop1b f1_DM_negOut_EX_DM(DM_negOut_EX_DM, negOut, clk, rst_n);
  flop1b f1_DM_ovOut_EX_DM(DM_ovOut_EX_DM, ovOut, clk, rst_n);
  flop4b f4_DM_ccc_EX_DM(DM_ccc_EX_DM, DM_ccc_ID_EX, clk, rst_n);
  flop1b f1_WB_RegWrite_EX_DM(WB_RegWrite_EX_DM, WB_RegWrite_ID_EX, clk, rst_n); // RegWrite

  flop16b f16_instr_EX_DM(instr_EX_DM, instr_ID_EX, clk, rst_n);
  flop1b f1_WB_hlt_EX_DM(WB_hlt_EX_DM, WB_hlt_ID_EX, clk, rst_n);
  flop4b f4_WB_dst_addr_EX_DM(WB_dst_addr_EX_DM, WB_dst_addr_ID_EX, clk, rst_n); // dst_addr

  // DM/WB BLOCK //
  flop1b f1_WB_RegWrite_DM_WB(WB_RegWrite_DM_WB, WB_RegWrite_EX_DM, clk, rst_n); // RegWrite
  flop16b f16_WB_dst_DM_WB(WB_dst_DM_WB, dst, clk, rst_n); // data to be written to register
  flop1b f16_WB_hlt_DM_WB(hlt, WB_hlt_EX_DM, clk, rst_n);
  flop4b f4_WB_dst_addr_DM_WB(WB_dst_addr_DM_WB, WB_dst_addr_EX_DM, clk, rst_n); // dst_addr


  // Extra flop for halt //


  //////////////////////
 // Forwarding SHIT  //
//////////////////////
forwardingUnit forwarding(.EX_Rs_Addr_ID_EX(EX_Rs_Addr_ID_EX),
                          .EX_Rt_Addr_ID_EX(EX_Rt_Addr_ID_EX),
                          .WB_dst_addr_EX_DM(WB_dst_addr_EX_DM),
                          .WB_dst_addr_DM_WB(WB_dst_addr_DM_WB),
                          .WB_RegWrite_EX_DM(WB_RegWrite_EX_DM),
                          .WB_RegWrite_DM_WB(WB_RegWrite_DM_WB),
                          .forwardA(forwardA),
                          .forwardB(forwardB));

  ////////////////////////////
 // Hazard Detection SHIT  //
////////////////////////////
hazardDetection hazardDetection(.WB_dst_addr_ID_EX(WB_dst_addr_ID_EX),
                                 .DM_MemRead_ID_EX(DM_MemRead_ID_EX),
                                 .instr_IF_ID(instr_IF_ID),
                                 .stall(stall));








endmodule