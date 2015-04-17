`define PROGRAM_BINARY "instr.hex"

module clk_and_rst_n;
    parameter CLK_INIT_VALUE=1;
    parameter HALF_CLOCK_PERIOD=5;
    parameter CYCLES_LIMIT=100000;
	reg clk, rst_n;
	wire halt;
    wire [15:0] PC_plus_1;
    integer total_cycles;

	cpu WISC_F14 (.clk(clk), .rst_n(rst_n), .hlt(halt), .pc(PC_plus_1));

    initial clk = CLK_INIT_VALUE;
    always #HALF_CLOCK_PERIOD clk <= ~clk;

    initial
    begin
        rst_n = 1'b0;
        #3;
        rst_n = 1'b1;
        @(posedge halt);
        #1;
        while (halt == 1'b0)
        begin
            @(posedge halt);
            #1;
        end
        $strobe("Time:    %7d\nCycles:   %6d\nPC:         %4h", $time, total_cycles, PC_plus_1);
        #10;
        $finish(0);
    end

    initial total_cycles = 16'h0000;

    always @ (posedge clk)
    begin
        total_cycles = total_cycles + 1'b1;
        if ($time > 2 * HALF_CLOCK_PERIOD * CYCLES_LIMIT)
        begin
            $strobe("ERROR at time %6d: simulation is running for too long; limit of %5d cycles exceeded!", $time, CYCLES_LIMIT);
            force halt = 1'b0;
            force halt = 1'b1;
            #10;
            $finish(-1);
        end
    end

endmodule
