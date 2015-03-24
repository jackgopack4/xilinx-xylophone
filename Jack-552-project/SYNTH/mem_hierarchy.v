module mem_hierarchy(clk, rst_n, instr, i_rdy, d_rdy, rd_data, i_addr, d_addr, re, we, wrt_data, allow_hlt);

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
                i_addr[15:2],
                i_wr_data, //m_rd_data,	
                1'b0,		// dirty bit set to 0
                i_we,		// enable write to cache
                1'b1,		// read enable set high
                i_rd_data,	// i_cache read out data is full block
                i_tag,		// tag of instr
                i_hit,		// high if hit
                i_dirty );	// high if dirty

  cache dCache( clk,
                rst_n,
                d_addr[15:2],
                d_wr_data,
                d_dirty_in,
                d_we,
                d_re,
                d_rd_data,
                d_tag,
                d_hit,
                d_dirty);
	
	cache_controller controller(.clk(clk),
                              .rst_n(rst_n),
                              .i_rdy(i_rdy),	// high when instr is ready to be read
                              .i_sel(i_sel),	// sel for instr output
                              .i_wr_data(i_wr_data),	// instr to write to cache
                              .i_we(i_we),		// enable write to cache
                              .m_addr(m_addr),	// mem addr (whether in cache or main mem)
                              .m_re(m_re),		// mem read enable
                              .m_we(m_we),		// mem write enable
                              .m_wr_data(m_wr_data),	// mem to write to cache
                              .i_addr(i_addr),	// taking full i_addr into conroller
                              .i_hit(i_hit),	// instr hit
                              .i_tag(i_tag),	// tag
                              .m_rd_data(m_rd_data),	// data read from mem
                              .m_rdy(m_rdy),	// mem ready? for hwat?
                              .re(re),			// read enable? for hwat?
                              .we(we),			// write enable?
                              .d_addr(d_addr),
                              .wrt_data(wrt_data),
                              .d_wr_data(d_wr_data),
                              .d_dirty_write(d_dirty_in),
                              .d_we(d_we),
                              .d_re(d_re),
                              .d_tag(d_tag),
                              .d_hit(d_hit),
                              .d_dirty_read(d_dirty),
                              .d_sel(d_sel),
                              .d_rd_data(d_rd_data),
                              .d_rdy(d_rdy),
                              .allow_hlt(allow_hlt));
	
	unified_mem memory( clk,
                      rst_n,
                      m_addr,	// addr in mem
                      m_re,		// read enable
                      m_we,		// write enable
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

  always@(posedge clk) begin
    /*$display("i_addr=%b\ni_wr_data=%b\ni_we=%b\ni_rd_data=%h\ni_tag=%b\ni_hit=%b\ni_dirty=%b\ninstr=%h\ni_sel=%b\n",
                i_addr[15:2],
                i_wr_data, //m_rd_data, 
                i_we,   // enable write to cache
                i_rd_data,  // i_cache read out data is full block
                i_tag,    // tag of instr
                i_hit,    // high if hit
                i_dirty,
                instr,
                i_sel); 
    */
    /*$display("d_addr=%b, d_wr_data=%h, d_dirt_in=%b, d_we=%b, d_re=%b\nd_rd_data=%h\nd_tag=%b, d_hit=%b, d_dirty=%b",
                d_addr[15:2],
                d_wr_data,
                d_dirty_in,
                d_we,
                d_re,
                d_rd_data,
                d_tag,
                d_hit,
                d_dirty); */
    /*$display( "m_addr=%b, m_re=%b, m_we=%b\nm_wr_data=%h\nm_rd_data=%h\nm_rdy=%b",
              m_addr, // addr in mem
              m_re,   // read enable
              m_we,   // write enable
              m_wr_data,  // data to write to mem
              m_rd_data,  // data read from mem
              m_rdy); */
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
