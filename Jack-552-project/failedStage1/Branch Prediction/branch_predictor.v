// Branch Predictor state machine
// Authors: David Hartman, John Peterson
// Date: 9 OCT 14
// Exercise 11
module branch_predictor(StateMSB, BR, Taken, clk, rst_n);

  input clk, rst_n;
  input BR, Taken;
  output StateMSB;

  reg [1:0] state, nxt_state;
  assign StateMSB = state[1];
  
  parameter Taken1    = 2'b00;
  parameter Taken2    = 2'b01;
  parameter NotTaken1 = 2'b10;
  parameter NotTaken2 = 2'b11;

  // State assignment logic
  always @(posedge clk, negedge rst_n) begin
    if(~rst_n)
      state <= Taken1;
    else
      state <= nxt_state;
    $display("State is: %b", state);
  end

  always @(state, BR, Taken) begin
    nxt_state = Taken1;
    case(state)
      Taken1 :   if(BR &  ~Taken)
                   nxt_state = Taken2;
      Taken2 :   if(~BR)
	           nxt_state = Taken2;
	         else if(BR & ~Taken)
		   nxt_state = NotTaken1;
      NotTaken1: if(BR & Taken)
	           nxt_state = Taken2;
	         else if(~BR)
		   nxt_state = NotTaken1;
	         else
		   nxt_state = NotTaken2;
      NotTaken2: if(BR & Taken)
	           nxt_state = NotTaken1;
	         else
		   nxt_state = NotTaken2;
      default:   nxt_state = Taken1;
    endcase
  end

endmodule
