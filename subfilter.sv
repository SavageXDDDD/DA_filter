module subfilter #(
parameter word_width = 16,
parameter filter_order = 3,
parameter intitial_file = "eqw",
parameter [word_width - 1 : 0] Q0_initial = 16'h1312
)(
input clk, 
input rst,
input D,
input Ts,
input shift_en,
input acc_en,
input SWa,
input SWb,

output shift_out,
output [word_width - 1 : 0] y
);

wire [filter_order : 0] x;
wire add_sub;

assign x[0] = D;
assign shift_out = x[filter_order];

assign add_sub = Ts ^ shift_out;

genvar i;
generate
    for (i = 0; i < filter_order; i = i + 1) begin
        param_reg #(word_width) shift_reg (clk, rst, shift_en, x[i], x[i + 1]);
    end
endgenerate

wire [word_width - 1 : 0] ROM_out;

fir_filter_ROM #(word_width, filter_order, intitial_file) fir_filter_ROM (clk, x[filter_order : 1], ROM_out);

wire [word_width - 1 : 0] add_sub_out;
wire [word_width - 1 : 0] SWb_out;
wire [word_width - 1 : 0] add_sub_shifted;

assign add_sub_out = add_sub ? SWb_out - ROM_out : SWb_out + ROM_out;

assign add_sub_shifted = add_sub_out >> 1;

assign SWb_out = SWb ? Q0_initial : add_sub_shifted;

assign {y, add_sub_shifted} = SWa ? {add_sub_out, '0} : {'0, add_sub_out >> 1};
    
endmodule