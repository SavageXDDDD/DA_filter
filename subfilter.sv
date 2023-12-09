`define FIRST_OR_SINGLE_SUBFILTER

module subfilter #(
parameter                      WORD_WIDTH      = 16,
parameter                      FILTER_ORDER    = 3,
parameter                      INIT_FILE   = "rom_1.mem",
parameter [WORD_WIDTH - 1 : 0] Q0_initial      = 16'h1312
//if 1 -> add shift register with parallel load
//parameter                      first_subfilter = 1
)(
input  logic                      clk, 
input  logic                      rst,
input  logic                      en,
input  logic                      ts,
//input  [first_subfilter * (WORD_WIDTH - 1) : 0] x,
`ifdef FIRST_OR_SINGLE_SUBFILTER
input  logic                      x_we,
input  logic [WORD_WIDTH - 1 : 0] x,
`else  
input  logic                      x,
`endif

`ifndef FIRST_OR_SINGLE_SUBFILTER
output logic                      shift_out,
`endif
output logic [WORD_WIDTH - 1 : 0] y
);

localparam ROM_ADDR_WIDTH = FILTER_ORDER;

logic [ROM_ADDR_WIDTH - 1 : 0] rom_address;
logic     [WORD_WIDTH - 1 : 0] rom_out;
logic     [WORD_WIDTH - 1 : 0] acc_out;

logic add_sub_ctrl;
assign add_sub_ctrl  = ts ^ rom_address[0]; 
logic [WORD_WIDTH - 1 : 0] add_sub_out;
logic [WORD_WIDTH - 1 : 0] acc_shifted;

assign acc_shifted = acc_out >> 1;

assign add_sub_out = add_sub_ctrl ? (acc_shifted + rom_out) 
                           : (rom_out - acc_shifted); //?????????????????????????????????

`ifndef FIRST_OR_SINGLE_SUBFILTER
assign shift_out = rom_address[ROM_ADDR_WIDTH - 1];
`endif

init_reg #(
  .WIDTH(WORD_WIDTH),
  .INIT_VAL(16'hD000)
) govno_reg (
  .clk(clk), 
  .rst(rst), 
  .en (add_sub_ctrl), 
  .D  (add_sub_out), 
  .Q  (acc_out)
);

fir_filter_rom #(
  .WORD_WIDTH(WORD_WIDTH),
  .ADDR_WIDTH(ROM_ADDR_WIDTH), 
  .INIT_FILE (INIT_FILE)
) fir_filter_rom (
  .address(rom_address),
  .en     (en),
  .data   (rom_out)
);

generate
  `ifdef FIRST_OR_SINGLE_SUBFILTER
  shift_reg_with_parellel_load #(
    .WIDTH(WORD_WIDTH)
  ) shift_reg_PL (
    .clk(clk), 
    .rst(rst), 
    .we (x_we), 
    .en (en), 
    .D  (x), 
    .Q  (rom_address[0])
  );
  `else 
  shift_reg #(
    .WIDTH(WORD_WIDTH)
  ) shift_reg (
    .clk(clk), 
    .rst(rst), 
    .en (en), 
    .D  (x), 
    .Q  (rom_address[0])
  );
  `endif

  for (genvar i = 1; i < FILTER_ORDER; i = i + 1) begin 
    shift_reg #(
      .WIDTH(WORD_WIDTH)
    ) shift_reg (
      .clk(clk), 
      .rst(rst), 
      .en (en), 
      .D  (rom_address[i - 1]), 
      .Q  (rom_address[i])
    );
  end
endgenerate

assign y = acc_out;

endmodule