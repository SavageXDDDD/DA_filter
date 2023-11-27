module fir_filter_ROM #(
parameter word_width  = 16,
parameter filter_order = 3,
parameter intitial_file = "eqw"
)(
input  logic                               clk, 
input  logic [filter_order - 1 : 0] addr,

output logic [word_width - 1          : 0] Q
);

logic [word_width - 1 : 0] mem [filter_order - 2 : 0];

initial begin
    $readmemh(intitial_file, mem);
end

logic [filter_order - 2 : 0] addr_int;

assign addr_int = addr[filter_order - 2 : 0] ^ {(filter_order - 1){addr[filter_order - 1]}};

always_ff @(posedge clk)
    Q <= mem [addr_int];

endmodule