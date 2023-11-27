module param_reg #(
parameter N = 20
)(
input  logic    clk,
input  logic    rst,
input  logic    en,
input  logic    D,
output logic    Q
);

logic [N - 1 : 0] shift_reg;

always_ff @(posedge clk) begin : blockName
    if (rst) 
        shift_reg <= 'b0;
    else if (en)
        shift_reg <= {shift_reg[N - 2 : 0], D};
end

assign Q = shift_reg[N - 1];

endmodule 