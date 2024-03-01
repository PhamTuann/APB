module fifomem
#(
  parameter DATASIZE = 32, // Memory data word width
  parameter ADDRSIZE = 4  // Number of mem address bits
)
(
  input   write_enable, write_full, write_clk,
  input   [ADDRSIZE-1:0] write_address, read_address,
  input   [DATASIZE-1:0] write_data,
  output  [DATASIZE-1:0] read_data
);

  // RTL Verilog memory model
  localparam DEPTH = 1<<ADDRSIZE;//2*addsize

  logic [DATASIZE-1:0] mem [0:DEPTH-1];

  assign read_data = mem[read_address];

  always_ff @(posedge write_clk)
    if (write_enable && !write_full)
      mem[write_address] <= write_data;

endmodule


module rptr_empty
#(
  parameter ADDRSIZE = 4
)
(
  input   read_enable, read_clk, read_reset_n,
  input   [ADDRSIZE :0] rq2_wptr,
  output reg  read_empty,
  output  [ADDRSIZE-1:0] read_address,
  output reg [ADDRSIZE :0] rptr
);

  reg [ADDRSIZE:0] rbin;
  wire [ADDRSIZE:0] rgraynext, rbinnext;
	reg [2:0] clk_count;
  //-------------------
  // GRAYSTYLE2 pointer
  //-------------------
    always_ff @(posedge read_clk or negedge read_reset_n)
    if (!read_reset_n)
      begin
        {rbin, rptr} <= '0;
        clk_count <= 0;
      end
    else begin
      if (clk_count < 2) // Check if it's the third clock cycle
        clk_count <= clk_count + 1;
	else {rbin, rptr} <= {rbinnext, rgraynext};
    end

  // Memory read-address pointer (okay to use binary to address memory)
  assign read_address = rbin[ADDRSIZE-1:0];
  assign rbinnext = rbin + (read_enable & ~read_empty);
  assign rgraynext = (rbinnext>>1) ^ rbinnext;

  //---------------------------------------------------------------
  // FIFO empty when the next rptr == synchronized wptr or on reset
  //---------------------------------------------------------------
  assign read_empty_val = (rgraynext == rq2_wptr);

  always_ff @(posedge read_clk or negedge read_reset_n)
    if (!read_reset_n)
      read_empty <= 1'b1;
    else
      read_empty <= read_empty_val;

endmodule

module sync_r2w
#(
  parameter ADDRSIZE = 4
)
(
  input   write_clk, write_reset_n,
  input   [ADDRSIZE:0] rptr,
  output reg  [ADDRSIZE:0] wq2_rptr//readpointer with write side
);

  reg [ADDRSIZE:0] wq1_rptr;

  always_ff @(posedge write_clk or negedge write_reset_n)
    if (!write_reset_n) {wq2_rptr,wq1_rptr} <= 0;
    else {wq2_rptr,wq1_rptr} <= {wq1_rptr,rptr};

endmodule

module sync_w2r
#(
  parameter ADDRSIZE = 4
)
(
  input   read_clk, read_reset_n,
  input   [ADDRSIZE:0] wptr,
  output reg [ADDRSIZE:0] rq2_wptr
);

  reg [ADDRSIZE:0] rq1_wptr;

  always_ff @(posedge read_clk or negedge read_reset_n)
    if (!read_reset_n)
      {rq2_wptr,rq1_wptr} <= 0;
    else
      {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};

endmodule

module wptr_full
#(
  parameter ADDRSIZE = 4
)
(
  input   write_enable, write_clk, write_reset_n,
  input   [ADDRSIZE :0] wq2_rptr,
  output reg  write_full,
  output  [ADDRSIZE-1:0] write_address,
  output reg [ADDRSIZE :0] wptr
);

   reg [ADDRSIZE:0] wbin;
  wire [ADDRSIZE:0] wgraynext, wbinnext;

 reg [2:0] clk_count; // Counter to count three clock cycles

  //-------------------
  // GRAYSTYLE2 pointer
  //-------------------
  always_ff @(posedge write_clk or negedge write_reset_n)  begin
    if (!write_reset_n)
      begin
        {wbin, wptr} <= '0;
        clk_count <= 0;
      end
    else begin
	if(write_enable) begin
      if (clk_count < 2) // Check if it's the third clock cycle
        clk_count <= clk_count + 1;
	else begin {wbin, wptr} <= {wbinnext, wgraynext}; end
	end 
	else clk_count <=0;
    end
end

  // Memory write-address pointer (okay to use binary to address memory)
  assign write_address = wbin[ADDRSIZE-1:0];
  assign wbinnext = wbin + (write_enable & ~write_full);
  assign wgraynext = (wbinnext>>1) ^ wbinnext;
  //------------------------------------------------------------------
  // Simplified version of the three necessary full-tests:
  // assign write_full_val=((wgnext[ADDRSIZE] !=wq2_rptr[ADDRSIZE] ) &&
  // (wgnext[ADDRSIZE-1] !=wq2_rptr[ADDRSIZE-1]) &&
  // (wgnext[ADDRSIZE-2:0]==wq2_rptr[ADDRSIZE-2:0]));
  //------------------------------------------------------------------
  assign write_full_val = (wgraynext=={~wq2_rptr[ADDRSIZE:ADDRSIZE-1], wq2_rptr[ADDRSIZE-2:0]});

  always_ff @(posedge write_clk or negedge write_reset_n)
    if (!write_reset_n)
      write_full <= 1'b0;
    else
      write_full <= write_full_val;

endmodule

module async_fifo
#(
  parameter DSIZE = 32,
  parameter ASIZE = 4
 )
(
  input   write_enable, write_clk, write_reset_n,//write_enable write enable signal
  input   read_enable, read_clk, read_reset_n,//read_enable read enable signal
  input   [DSIZE-1:0] write_data,

  output  [DSIZE-1:0] read_data,
  output  write_full,
  output  read_empty
);

  wire [ASIZE-1:0] write_address, read_address;
  wire [ASIZE:0] wptr, rptr, wq2_rptr, rq2_wptr;

  sync_r2w sync_r2w (.*);
  sync_w2r sync_w2r (.*);
  fifomem #(DSIZE, ASIZE) fifomem (.*);
  rptr_empty #(ASIZE) rptr_empty (.*);
  wptr_full #(ASIZE) wptr_full (.*);

endmodule