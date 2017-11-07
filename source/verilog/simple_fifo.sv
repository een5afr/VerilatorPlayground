module simple_fifo
#(
  DATA_WIDTH=32, 
  FIFO_DEPTH=16,
  ALMOST_FULL=12,
  ALMOST_EMPTY=4
)
( 
  input   clk,
  input   reset_n,
  //
  input   [DATA_WIDTH-1:0]  wdata,
  input                     wval,
  output                    wack,
  //
  output  [DATA_WIDTH-1:0]  rdata,
  output                    rval,
  input                     rack,
  //
  output                    almost_full,
  output                    almost_empty
);

logic full, 
      empty;
      
logic w_wrap, 
      r_wrap;

logic [($clog2(FIFO_DEPTH))-1:0] w_ptr, r_ptr; 

logic [DATA_WIDTH-1:0] mem_array [FIFO_DEPTH-1:0];

// Flags 
assign full   = (w_ptr == r_ptr) && (w_wrap != r_wrap);
assign empty  = (w_ptr == r_ptr) && (w_wrap == r_wrap);

assign rval = !empty;
assign wack = !full;

assign almost_full  = 1'b0; //(w_wrap != r_wrap)? (r_ptr - w_ptr) < ALMOST_FULL : 
                            // (($clog2(FIFO_DEPTH)- w_ptr) + r_ptr) < ALMOST_FULL;
                                         
assign almost_empty = 1'b0; //(w_wrap != r_wrap)? 

// Toggle Regs
always_ff @(posedge clk or negedge reset_n) 
  if (!reset_n)
    w_wrap <= 1'b0;
  else if  (wval && wack && &(w_ptr))
    w_wrap <= ~w_wrap;

always_ff @(posedge clk or negedge reset_n) 
  if (!reset_n)
    r_wrap <= 1'b0;
  else if  (rval && rack && &(r_ptr))
    r_wrap <= ~r_wrap;

// Read & Write Pointers
always_ff @(posedge clk or negedge reset_n) 
  if (!reset_n)
    r_ptr <= 0;
  else if  (rval && rack)
    r_ptr <= ($clog2(FIFO_DEPTH))'(r_ptr+1'b1);

always_ff @(posedge clk or negedge reset_n) 
  if (!reset_n)
    w_ptr <= 0;
  else if  (wval && wack)
    w_ptr <= ($clog2(FIFO_DEPTH))'(w_ptr+1'b1);

// Memory Reads & Writes
always_ff @(posedge clk)
  if (wval && wack)
    mem_array[w_ptr] <= wdata;

assign rdata = mem_array[r_ptr];

endmodule




