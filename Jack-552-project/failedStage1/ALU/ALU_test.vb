module ALU_test(src0, src1, op, dst, ov, zr, neg, shamt);

input [15:0] src0, src1;
input [3:0] op, shamt;
output [15:0] dst;
output ov, zr, neg;

localparam ADD = 4'b0000;

assign dst = (op == ADD) ? (src0 + src1) : -1;




endmodule


/*

module ALU( dst, ov, zr, neg, src0, src1, op, shamt);

    output [15:0] dst;
    output ov, zr, neg; // Signals for flags
    input [15:0] src0, src1;
    input [3:0] op;     // op code determines control
    input [3:0] shamt;  // how much src0 is shifted

    localparam ADD     = 4'b0000;
    localparam PADDSB  = 4'b0001;
    localparam SUB     = 4'b0010;
    localparam AND     = 4'b0011;
    localparam NOR     = 4'b0100;
    localparam SLL     = 4'b0101;
    localparam SRL     = 4'b0110;
    localparam SRA     = 4'b0111;
    localparam LLB     = 4'b1010;
    localparam LHB     = 4'b1011;
   
   assign dst = src0 + src1;


endmodule

*/
