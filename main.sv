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
logic [WORD_WIDTH - 1 : 0] fir_in [SUBFILTER_COUNT - 1 : 0];
logic filter_en;
logic ts;
logic x_we;
logic zeros [WORD_WIDTH - 5 : 0] = '{default: '0};

always_ff @(posedge clk) begin

  fir_in[0] = {{x[15]}, {x[11]}, {x[7]}, {x[3]}, {12{1'b0}}};
  fir_in[1] = {{x[14]}, {x[10]}, {x[6]}, {x[2]}, {12{1'b0}}};
  fir_in[2] = {{x[13]}, {x[9] }, {x[5]}, {x[1]}, {12{1'b0}}};
  fir_in[3] = {{x[12]}, {x[8] }, {x[4]}, {x[0]}, {12{1'b0}}};

end

always_comb begin 
  filter_out = 'h0;
  for (integer j = 0; j < SUBFILTER_COUNT; j = j + 1) begin 
    filter_out = filter_out + ($signed(subfilter_out[j]) >>> j);
  end
end

filter_cu #(
  .WORD_WIDTH(WORD_WIDTH / 4)
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
      .x   (fir_in[i]),
      .y   (subfilter_out[i])
    );
    end
endgenerate

assign y = ts ? filter_out : 'h0;

endmodule