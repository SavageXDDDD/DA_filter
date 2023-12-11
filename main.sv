module main #(
parameter WORD_WIDTH = 16,
parameter SUBFILTER_COUNT = 4,
parameter SUBFILTER_ORDER = 5,
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
    filter_out = filter_out + ($signed(subfilter_out[j]) >>> j);
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

    for (genvar i = 0; i < SUBFILTER_COUNT; i = i + 1) begin 
      subfilter_only #(
      .WORD_WIDTH  (WORD_WIDTH),
      .FILTER_ORDER(SUBFILTER_ORDER),
      .INIT_FILE   ("rom_1.mem"),
      .Q0_initial  (16'hB000)
    ) subfilter (
      .clk (clk), 
      .rst (rst),
      .en  (filter_en),
      .ts  (ts),
      .x_we(x_we),
      .x   ({{x[WORD_WIDTH - 1 - i]}, 
            {x[WORD_WIDTH - BAAT - 1 - i]},
            {x[WORD_WIDTH - (BAAT * 2) - 1 - i]},
            {x[WORD_WIDTH - (BAAT * 3) - 1 - i]},
            {'h000}}),
      .y   (subfilter_out[i])
    );
    end
endgenerate

assign y = ts ? filter_out : 'h0;

endmodule