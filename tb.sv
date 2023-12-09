`define FIRST_OR_SINGLE_SUBFILTER

module tb ();

logic clk;
logic rst;
logic en;
logic ts;
logic x_we;
logic [15 : 0] x;
logic [15 : 0] y;
logic shift_out;

subfilter #(
  .WORD_WIDTH  (16),
  .FILTER_ORDER(3),
  .INIT_FILE   ("rom_1.mem"),
  .Q0_initial  (16'h1312)
//if 1 -> add shift register with parallel load
//parameter                      first_subfilter = 1
) subfilter (
  .clk(clk), 
  .rst(rst),
  .en(en),
  .ts(ts),
//input  [first_subfilter * (WORD_WIDTH - 1) : 0] x,
`ifdef FIRST_OR_SINGLE_SUBFILTER
  .x_we(x_we),
  .x(x),
`else  
  .x(x),
`endif

`ifndef FIRST_OR_SINGLE_SUBFILTER
  .shift_out(shift_out),
`endif
  .y(y)
);



initial begin
  clk = 1'b1;
  forever begin
    #50 clk = ~clk;
  end
end

initial begin 
  #100;
  #100;
  rst = 1;
  en = 0;
  ts = 0;
  x_we = 0;
  x = 16'h4000;
  #100;
  rst = 0;
  #100;
  x_we = 1;
  #100;
  x_we = 0;
  #100;
  #100;
  #100;
  en = 1;
  #(100 * 14);
  ts = 1;
  #100;
  ts = 0;
  en = 0;

end



endmodule 