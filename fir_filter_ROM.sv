module fir_filter_ROM #(
parameter word_width    = 16,
parameter address_width = 3,
parameter intitial_file = "file name"
)(
input logic  [address_width - 1 : 0] address,
input logic                          en,

output logic [word_width - 1 : 0]    data
);

logic [word_width - 1 : 0] mem [address_width - 2 : 0];
//internal address for offset binary coding
logic [address_width - 2 : 0] address_int;

//initial memory from file
initial begin
    $readmemh(intitial_file, mem);
end

//binary offeset address decoding
assign address_int = address[address_width - 2 : 0] ^ 
                   {(address_width - 1){address[address_width - 1]}};

assign data = en ? mem[address_int] : 'b0;

endmodule