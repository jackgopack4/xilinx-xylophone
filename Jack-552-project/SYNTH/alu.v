module alu(clk,src0,src1,shamt,func,dst,dst_EX_DM,ov,zr,neg, padd,stall_EX_DM);
///////////////////////////////////////////////////////////
// ALU.  Performs ADD, SUB, AND, NOR, SLL, SRL, or SRA  //
// based on func input.  Provides OV and ZR outputs.   //
// Arithmetic is saturating.                          //
///////////////////////////////////////////////////////
// Encoding of func[2:0] is as follows: //
// 000 ==> ADD
// 001 ==> SUB
// 010 ==> AND
// 011 ==> NOR
// 100 ==> SLL
// 101 ==> SRL
// 110 ==> SRA
// 111 ==> reserved

//////////////////////
// include defines //
////////////////////
`include "common_params.inc"

input clk;
input [15:0] src0,src1;
input [2:0] func;			// selects function to perform
input [3:0] shamt;			// shift amount
input stall_EX_DM;
input padd;


output [15:0] dst;			// ID_EX version for branch/jump targets
output reg [15:0] dst_EX_DM;
output ov,zr,neg;

wire [15:0] sum;		// output of adder
wire [15:0] sum_sat;	// saturated sum
wire [15:0] src0_2s_cmp;
wire cin;
wire [15:0] shft_l1,shft_l2,shft_l4,shft_l;		// intermediates for shift left
wire [15:0] shft_r1,shft_r2,shft_r4,shft_r;		// intermediates for shift right

/////////////////////////////////////////////////
// Implement 2s complement logic for subtract //
///////////////////////////////////////////////
assign src0_2s_cmp = (func==SUB) ? ~src0 : src0;	// use 2's comp for sub
assign cin = (func==SUB) ? 1 : 0;					// which is invert and add 1
///////////////////////////////
// Now for PADDSB logic //
/////////////////////////////
wire [15:0] sum_padd;
wire [7:0] left_sum, right_sum, left_sum_sat, right_sum_sat;
wire left_sat_neg, left_sat_pos, right_sat_neg, right_sat_pos;
wire cin_right_to_left, cin_real_right_to_left; 

assign {cin_right_to_left, right_sum} = src0_2s_cmp[7:0] + src1[7:0] + cin;
assign cin_real_right_to_left = padd? 0 : cin_right_to_left;
assign left_sum = src0_2s_cmp[15:8] + src1[15:8] + cin_real_right_to_left;

assign left_sat_neg = (~left_sum[7] && src0_2s_cmp[15] && src1[15]) ? 1 : 0;
assign left_sat_pos = (left_sum[7] && ~src0_2s_cmp[15] && ~src1[15]) ? 1 : 0;
assign right_sat_neg = (~right_sum[7] && src0_2s_cmp[7] && src1[7]) ? 1 : 0;
assign right_sat_pos = (right_sum[7] && ~src0_2s_cmp[7] && ~src1[7]) ? 1 : 0;

assign left_sum_sat = (left_sat_pos) ? 8'h7f:
                      (left_sat_neg) ? 8'h80: left_sum;
assign right_sum_sat = (right_sat_pos) ? 8'h7f:
                       (right_sat_neg) ? 8'h80: right_sum;

assign sum_padd = {left_sum_sat, right_sum_sat};


//////////////////////
// Implement adder //
////////////////////
assign sum = {left_sum, right_sum};

///////////////////////////////
// Now for saturation logic //
/////////////////////////////
assign sat_neg = (src1[15] && src0_2s_cmp[15] && ~sum[15]) ? 1 : 0;
assign sat_pos = (~src1[15] && !src0_2s_cmp[15] && sum[15]) ? 1 : 0;
assign sum_sat = (sat_pos) ? 16'h7fff :
                 (sat_neg) ? 16'h8000 :
				 sum;

assign ov = sat_pos | sat_neg;

				 
///////////////////////////
// Now for left shifter //
/////////////////////////
assign shft_l1 = (shamt[0]) ? {src1[14:0],1'b0} : src1;
assign shft_l2 = (shamt[1]) ? {shft_l1[13:0],2'b00} : shft_l1;
assign shft_l4 = (shamt[2]) ? {shft_l2[11:0],4'h0} : shft_l2;
assign shft_l = (shamt[3]) ? {shft_l4[7:0],8'h00} : shft_l4;

////////////////////////////
// Now for right shifter //
//////////////////////////
assign shft_in = (func==SRA) ? src1[15] : 0;
assign shft_r1 = (shamt[0]) ? {shft_in,src1[15:1]} : src1;
assign shft_r2 = (shamt[1]) ? {{2{shft_in}},shft_r1[15:2]} : shft_r1;
assign shft_r4 = (shamt[2]) ? {{4{shft_in}},shft_r2[15:4]} : shft_r2;
assign shft_r = (shamt[3]) ? {{8{shft_in}},shft_r4[15:8]} : shft_r4;

///////////////////////////////////////////
// Now for multiplexing function of ALU //
/////////////////////////////////////////
assign dst = (padd)? sum_padd:
	     (func==AND) ? src1 & src0 :
	     (func==NOR) ? ~(src1 | src0) :
	     (func==SLL) ? shft_l :
	     ((func==SRL) || (func==SRA)) ? shft_r :
	     (func==LHB) ? {src1[7:0],src0[7:0]} : sum_sat;	 
			 
assign zr = ~|dst;
assign neg = dst[15];

//////////////////////////
// Flop the ALU result //
////////////////////////
always @(posedge clk)
  if (!stall_EX_DM) begin
  	dst_EX_DM <= dst;
  end
endmodule
