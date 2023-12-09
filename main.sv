module main #(
parameter WORD_WIDTH = 16,
parameter SUBFILTER_COUNT = 3,
parameter SUBFILTER_ORDER = 3,
parameter INIT_FILE       = "rom_1.mem"
)(
input  logic                      clk, 
input  logic                      rst, 
input  logic                      en,
input  logic [WORD_WIDTH - 1: 0]  x,

output logic [WORD_WIDTH - 1 : 0] y
);

logic [WORD_WIDTH - 1 : 0] subfilter_out [SUBFILTER_COUNT - 1 : 0];
logic [WORD_WIDTH - 1 : 0] filter_out;

logic filter_en;
logic ts;
logic x_we;

always_comb begin 
  filter_out = 'h0;
  for (integer j = 0; j < SUBFILTER_COUNT; j = j + 1) begin 
    filter_out = filter_out + subfilter_out[j];
  end
end

filter_cu #(
  .WORD_WIDTH(WORD_WIDTH)
) filter_cu (
  .clk      (clk), 
  .rst      (rst),
  .en       (en),
  .filter_en(filter_en),
  .x_we     (x_we),
  .ts       (ts)
);

generate
  if (SUBFILTER_COUNT == 1) begin   
    subfilter_only #(
      .WORD_WIDTH  (WORD_WIDTH),
      .FILTER_ORDER(SUBFILTER_ORDER),
      .INIT_FILE   ("rom_1.mem"),
      .Q0_initial  (16'hd000)
    ) subfilter (
      .clk (clk), 
      .rst (rst),
      .en  (filter_en),
      .ts  (ts),
      .x_we(x_we),
      .x   (x),
      .y   (subfilter_out[0])
    );
  end
  if (SUBFILTER_COUNT > 1) begin 
    
    logic [SUBFILTER_COUNT - 2 : 0] shift_out;

    subfilter_first #(
      .WORD_WIDTH  (WORD_WIDTH),
      .FILTER_ORDER(SUBFILTER_ORDER),
      .INIT_FILE   ("rom_1.mem"),
      .Q0_initial  (16'hd000)
    ) subfilter_first (
      .clk      (clk), 
      .rst      (rst),
      .en       (filter_en),
      .ts       (ts),
      .x_we     (x_we),
      .x        (x),
      .shift_out(shift_out[0]),
      .y        (subfilter_out[0])
    );

    for (genvar i = 1; i < SUBFILTER_COUNT - 1; i = i + 1) begin 
      subfilter #(
        .WORD_WIDTH  (WORD_WIDTH),
        .FILTER_ORDER(SUBFILTER_ORDER),
        .INIT_FILE   ("rom_1.mem"),
        .Q0_initial  (16'hd000)
      ) subfilter (
        .clk      (clk), 
        .rst      (rst),
        .en       (filter_en),
        .ts       (ts),
        .x        (shift_out[i - 1]),
        .shift_out(shift_out[i]),
        .y        (subfilter_out[i])
      );
    end
   
    subfilter_last #(
      .WORD_WIDTH  (WORD_WIDTH),
      .FILTER_ORDER(SUBFILTER_ORDER),
      .INIT_FILE   ("rom_1.mem"),
      .Q0_initial  (16'hd000)
    ) subfilter_last (
      .clk(clk), 
      .rst(rst),
      .en (filter_en),
      .ts (ts),
      .x  (shift_out[SUBFILTER_COUNT - 2]),
      .y  (subfilter_out[SUBFILTER_COUNT - 1])
    );

  end
endgenerate

assign y = ts ? filter_out : 'h0;

endmodule