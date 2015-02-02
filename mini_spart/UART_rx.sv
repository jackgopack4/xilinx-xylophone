module UART_rx(clk, rst_n, RX, clr_rdy, rx_data, rdy);

///////////////////
// Input/Outputs //
///////////////////
input clk, rst_n, RX, clr_rdy;

output [7:0] rx_data;
output reg rdy;

////////////
// States //
//////////// 
typedef enum reg [1:0] {IDLE, STRTBIT, RCV, WAIT_RDY} state_t;
state_t state, nxt_state;

///////////////
// Registers //
///////////////
reg [7:0] rx_shift_reg;
reg [5:0] baud_cnt;
reg [3:0] bit_cnt;
reg RX_ff1, RX_ff2;

logic shift, rst_bit_cnt, rst_baud_cnt, strt_shift, rdy_en;
wire negedgeRX;

/////////////////////
//Flop for rx_shift//
/////////////////////
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		rx_shift_reg <= 8'h00;
	else if (shift)
		rx_shift_reg <= {RX_ff2, rx_shift_reg[7:1]};
end

assign rx_data = rx_shift_reg;

//////////////////
//Double flop RX//
//////////////////
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		RX_ff1 <= 1'b1;
		RX_ff2 <= 1'b1;
	end
	else begin
		RX_ff1 <= RX;
		RX_ff2 <= RX_ff1;
	end
end

//detects negative edge of start bit
assign negedgeRX = (RX_ff2 && ~RX_ff1);

////////////////////////
//Flop for bit counter//
////////////////////////
always_ff @(posedge clk) begin
	if (rst_bit_cnt)
		bit_cnt <= 4'b0000;
	else if (shift)
		bit_cnt <= (bit_cnt + 1);
end

/////////////////////////
//Flop for baud (shift)//
/////////////////////////
always_ff @(posedge clk) begin
	if (rst_baud_cnt)
		baud_cnt <= 6'b000000;
	else
		baud_cnt <= (baud_cnt + 1);
end

//shift when baud cnt = 43
assign shift = (baud_cnt == 6'b101001) ? 1'b1 : 1'b0;
//buffer for start bit is 20 (20 + 43 = 63)
assign strt_shift = (baud_cnt == 6'b010100) ? 1'b1 : 1'b0;

//flop for state
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) 
		state <= IDLE;
	else
		state <= nxt_state;
end

always_comb begin
	//default outputs
	rst_baud_cnt = 0;
	rst_bit_cnt = 0;
	rdy = 1;

	case (state)
		IDLE: begin
			rdy = 1;
			rst_baud_cnt = 1;
			if(clr_rdy) begin
				rdy = 0;
				nxt_state = IDLE;
			end
			else if (negedgeRX) begin //otherwise, check start bit
				nxt_state = STRTBIT;
			end
			else
				nxt_state = IDLE;
		end
		STRTBIT: begin //handles start bit
			rdy = 0;
			if (strt_shift) begin //counts 1.5 baud periods
				rst_baud_cnt = 1;
				rst_bit_cnt = 1;
				nxt_state = RCV;
			end else
				nxt_state = STRTBIT;
		end
		RCV: begin //receive the data
			rdy = 0;
			if (shift) 
				rst_baud_cnt = 1;
			if (bit_cnt==4'h8) begin //done after 8 bits
				rst_baud_cnt = 1;
				nxt_state = WAIT_RDY;
			end else
				nxt_state = RCV;
		end
		WAIT_RDY: begin
			rdy = 0;
			if (&baud_cnt[4:0]) begin //waits to assert rdy
				nxt_state = IDLE;
			end
			else
				nxt_state = WAIT_RDY;
		end
	endcase
end

endmodule
		
