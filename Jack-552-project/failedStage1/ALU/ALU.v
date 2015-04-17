module ALU( dst,
	    change_v,
	    change_z,
	    change_n,
      ov,
      zr, 
      neg,
	    src0,
	    src1,
	    op,
	    shamt);

  localparam ADD = 4'b0000;
  localparam PADDSB = 4'b0001;
  localparam SUB = 4'b0010;
  localparam AND = 4'b0011;
  localparam NOR = 4'b0100;
  localparam SLL = 4'b0101;
  localparam SRL = 4'b0110;
  localparam SRA = 4'b0111;
  localparam LW = 4'b1000;
  localparam SW = 4'b1001;
  localparam LHB = 4'b1010;
  localparam LLB = 4'b1011;
  localparam B = 4'b1100;
  localparam JAL = 4'b1101;
  localparam JR = 4'b1110;
  localparam HLT = 4'b1111;

  output [15:0] dst;
  output ov, zr, neg; // Signals for flags
  output reg change_v, change_z, change_n;
  input [15:0] src0, src1;
  input [3:0] op;     // op code determines control
  input [3:0] shamt;  // how much src0 is shifted

  wire [15:0] arithout, logicout, shiftout, loadout;
  wire [1:0] Sel;
  wire v_arith, n_arith, z_arith, z_logic, z_shift;
  wire mem_add;
  assign mem_add = (op[3:1] == 3'b100) ? 1'b1: 1'b0; // if load or store, bypass op[1:0] in arithmod and just add.

  arithmod am(arithout, v_arith, n_arith, z_arith, src0, src1, op[1:0], mem_add);
  logicmod lm(logicout, z_logic, src0, src1, op[2]);
  shiftmod sm(shiftout, z_shift, src0, op[1:0], shamt);
  loadmod  dm(loadout, src0, src1, op[0]);

  assign Sel = (op[3:1] == 3'b000 || op == 4'b0010|| op[3:1] == 3'b100)  ? 2'b00 :
	       ((op == 4'b0011 || op == 4'b0100)  ? 2'b01 :
	       ((op == 4'b0101 || op[3:1] == 3'b011) ? 2'b10 :
	                                           2'b11));

//  always@(Sel) $display("Sel changed to: %b", Sel);
//  always@(op) $display("op changed to: %b", op);
  assign ov = (Sel == 2'b00) ? v_arith : 1'b0;
  assign zr = (Sel == 2'b00) ? z_arith :
             ((Sel == 2'b01) ? z_logic :
             ((Sel == 2'b10) ? z_shift :
                               1'b0));
  assign neg = (Sel == 2'b00) ? n_arith : 1'b0;
  always@(ov, neg, zr) begin
  case(op)
    ADD: begin
      change_z <= 1'b1;
      change_v <= 1'b1;
      change_n <= 1'b1;
    end
    SUB: begin
      change_z <= 1'b1;
      change_v <= 1'b1;
      change_n <= 1'b1;
    end
    AND: begin
      change_z <= 1'b1;
    end
    NOR: begin
      change_z <= 1'b1;
    end
    SLL: begin
      change_z <= 1'b1;
    end
    SRL: begin
      change_z <= 1'b1;
    end
    SRA: begin
      change_z <= 1'b1;
    end
    default: begin
      change_z <= 1'b0;
      change_v <= 1'b0;
      change_n <= 1'b0;
    end
  endcase
  end

  assign dst = (Sel == 2'b00)  ? arithout :
	       ((Sel == 2'b01) ? logicout :
	       ((Sel == 2'b10) ? shiftout :
	                         loadout));

endmodule
