module mem_hierarchy(clk, rst_n, instr, i_rdy, d_rdy, rd_data, i_addr, d_addr, re, we, wrt_data, allow_hlt);
	// Authors: David Hartman and John Peterson
    // Course: ECE552
    // Date modified: 12 Dec 2014
	// module to control cache reads and writes, contained inside of mem_hierarchy 
  
  input clk, rst_n, re, we;
  input [15:0] i_addr, d_addr, wrt_data;

  output i_rdy, d_rdy;
  output reg [15:0] instr, rd_data;
  output allow_hlt;
  
  wire [63:0] i_rd_data, i_wr_data;
  wire [7:0] i_tag;
  wire i_hit, i_dirty, i_we;
  wire [1:0] i_sel;

  wire [63:0] d_rd_data, d_wr_data;
  wire [7:0] d_tag;
  wire d_hit, d_dirty, d_we, d_dirty_in, d_re;
  wire [1:0] d_sel;

  wire [13:0] m_addr;
  wire m_re, m_we, m_rdy;
  wire [63:0] m_wr_data, m_rd_data;
  
	cache iCache( clk,
                rst_n,
                i_addr[15:2],// address of instruction with 2 LSB dropped (offset)
                i_wr_data,   // data to write to cache from m_rd_data,	
                1'b0,		 // dirty bit set to 0
                i_we,		 // enable write to cache
                1'b1,		 // read enable set high
                i_rd_data,	 // i_cache read out data is full block
                i_tag,		 // high if hit
                i_hit,		 // high if hit
                i_dirty );	 // high if dirty

  cache dCache( clk,
                rst_n,
                d_addr[15:2],// address of data with 2 LSB dropped (offset)
                d_wr_data,	 // data to write to cache from m_rd_data	
                d_dirty_in,	 // high if block is dirty
                d_we,		 // enable write to cache
                d_re,		 // enable to read from cache
                d_rd_data,	 // d_cache read out data is full block
                d_tag,		 // high if hit
                d_hit,		 // high if hit
                d_dirty);	 // high if dirty
	
	cache_controller controller(.clk(clk),
                              .rst_n(rst_n),
                              .i_rdy(i_rdy),			 // high when instr is ready to be read
                              .i_sel(i_sel),			 // sel for instr output
                              .i_wr_data(i_wr_data),	 // instr to write to i_cache
                              .i_we(i_we),				 // enable write to i_cache
                              .m_addr(m_addr),			 // mem addr (whether in cache or main mem)
                              .m_re(m_re),				 // mem read enable
                              .m_we(m_we),				 // mem write enable
                              .m_wr_data(m_wr_data),	 // mem to write to cache
                              .i_addr(i_addr),			 // taking full i_addr into conroller
                              .i_hit(i_hit),			 // instr hit
                              .i_tag(i_tag),			 // i tag
                              .m_rd_data(m_rd_data),	 // data read from mem
                              .m_rdy(m_rdy),			 // input from memory if ready to read/write
                              .re(re),					 // read enable for memory
                              .we(we),					 // write enable for memory
                              .d_addr(d_addr),			 // taking full d_addr into conroller
                              .wrt_data(wrt_data),		 // address and data to write to memory for data
                              .d_wr_data(d_wr_data),	 // data to write to to memory
                              .d_dirty_write(d_dirty_in),// high if data is dirty
                              .d_we(d_we),				 // enable write to d_cache
                              .d_re(d_re),				 // enable read from d_cache
                              .d_tag(d_tag),			 // tag of data address
                              .d_hit(d_hit),			 // high if d_cache hit
                              .d_dirty_read(d_dirty),	 // high if read from dirty block
                              .d_sel(d_sel),			 // select for d_cache block offset
                              .d_rd_data(d_rd_data),	 // data read from d_cache
                              .d_rdy(d_rdy),			 // high when d_cache is ready to be read
                              .allow_hlt(allow_hlt));	 // high when hlt is allowed to propagate
	
	unified_mem memory( clk,
                      rst_n,
                      m_addr,		// addr in mem
                      m_re,			// read enable
                      m_we,			// write enable
                      m_wr_data,	// data to write to mem
                      m_rd_data,	// data read from mem
                      m_rdy);		// mem has finished reading/writing


  
  // mux for instruction output
  always@(negedge clk) begin
    if     (i_sel == 2'b00) instr = i_rd_data[15:0];
    else if(i_sel == 2'b01) instr = i_rd_data[31:16];
    else if(i_sel == 2'b10) instr = i_rd_data[47:32];
    else                    instr = i_rd_data[63:48];
  end

  // mux for data read output
  always@(negedge clk) begin
    if     (d_sel == 2'b00) rd_data = d_rd_data[15:0];
    else if(d_sel == 2'b01) rd_data = d_rd_data[31:16];
    else if(d_sel == 2'b10) rd_data = d_rd_data[47:32];
    else                    rd_data = d_rd_data[63:48];
  end


// test output //
/*
always @(*) begin
		$display("m_rdy=%b, i_rdy=%b, i_hit=%b, i_sel=%b, instr=%h,\n m_rd_data=%h, i_rd_data=%h, i_we=%b,\n i_wr_data=%h, m_re=%b, i_addr=%h\n", m_rdy, i_rdy, i_hit, i_sel, instr, m_rd_data, i_rd_data, i_we, i_wr_data, m_re, i_addr);
		//$display("instr=%h\n",instr);
	end  
*/
  
  
endmodule
