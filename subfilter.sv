`define FIRST_OR_SINGLE_SUBFILTER 1

module subfilter #(
parameter                      word_width      = 16,
parameter                      filter_order    = 3,
parameter                      intitial_file   = "file_name",
parameter [word_width - 1 : 0] Q0_initial      = 16'h1312
//if 1 -> add shift register with parallel load
//parameter                      first_subfilter = 1
)(
input                                           clk, 
input                                           rst,
input                                           en,
input                                           Ts,
//input  [first_subfilter * (word_width - 1) : 0] x,
`ifdef FIRST_OR_SINGLE_SUBFILTER
input x_we,
input  [word_width - 1 : 0] x,
`else 
input  x,
`endif

`ifndef FIRST_OR_SINGLE_SUBFILTER
output                                          shift_out,
`endif
output [word_width - 1 : 0] y
);

localparam ROM_address_width = filter_order;

logic [ROM_address_width - 1 : 0] ROM_address;
logic [word_width - 1 : 0] ROM_out;

logic add_sub_ctrl = Ts ^ ROM_address[0]; 

`ifndef FIRST_OR_SINGLE_SUBFILTER
assign shift_out = ROM_address[ROM_address_width - 1];
`endif

fir_filter_ROM #(
.word_width(word_width),
.address_width(ROM_address_width), 
.intitial_file(intitial_file)
) fir_filter_ROM (
.address(ROM_address),
.en(en),
.data(ROM_out)
);

genvar i;
generate
    `ifdef FIRST_OR_SINGLE_SUBFILTER
    shift_reg_with_parellel_load #(
    .N(word_width)
    ) shift_reg_PL (
    .clk(clk), 
    .rst(rst), 
    .we(x_we), 
    .en(en), 
    .D(x), 
    .Q(ROM_address[0])
    );
    `else 
    shift_reg #(
    .N(word_width)
    ) shift_reg (
    .clk(clk), 
    .rst(rst), 
    .en(en), 
    .D(x), 
    .Q(ROM_address[0])
    );
    `endif

    for (i = 1; i < filter_order; i = i + 1)
        shift_reg #(
        .N(word_width)
        ) shift_reg (
        .clk(clk), 
        .rst(rst), 
        .en(en), 
        .D(ROM_address[i - 1]), 
        .Q(ROM_address[i])
        );
endgenerate

assign y = ROM_out;

//wire [word_width - 1 : 0] add_sub_out;
//wire [word_width - 1 : 0] SWb_out;
//wire [word_width - 1 : 0] add_sub_shifted;
//
//assign add_sub_out = add_sub ? SWb_out - ROM_out : SWb_out + ROM_out;
//
//assign add_sub_shifted = add_sub_out >> 1;
//
//assign SWb_out = SWb ? Q0_initial : add_sub_shifted;
//
//assign {y, add_sub_shifted} = SWa ? {add_sub_out, '0} : {'0, add_sub_out >> 1};
    
endmodule