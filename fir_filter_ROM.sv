module fir_filter_rom #(
parameter WORD_WIDTH = 16,
parameter ADDR_WIDTH = 3,
parameter INIT_FILE  = "file name"
)(
input  logic [ADDR_WIDTH - 1 : 0] address,
input  logic                      en,

output logic [WORD_WIDTH - 1 : 0] data
);

logic [WORD_WIDTH - 1 : 0] mem [2**(ADDR_WIDTH - 1) - 1 : 0];
//internal address for offset binary coding
logic [ADDR_WIDTH - 2 : 0] address_int;

//initial memory from file
initial begin
  $readmemh(INIT_FILE, mem);
end

//binary offeset address decoding
assign address_int = address[ADDR_WIDTH - 1 : 1] ^ 
                   {(ADDR_WIDTH - 1){address[0]}};

assign data = en ? mem[address_int] : 'b0;

endmodule