module init_reg #(
parameter WIDTH = 20,
parameter [WIDTH - 1 : 0] INIT_VAL = 20'hf0
)(
input  logic                 clk,
input  logic                 rst,
input  logic                 en,
input  logic [WIDTH - 1 : 0] D,

output logic [WIDTH - 1 : 0] Q
);

always_ff @(posedge clk) begin
  if (rst) 
    Q <= INIT_VAL;
  else if (en)
    Q <= D;
end

endmodule 



module shift_reg #(
parameter WIDTH = 20
)(
input  logic clk,
input  logic rst,
input  logic en,
input  logic D,

output logic Q
);

logic [WIDTH - 1 : 0] shift_reg;

always_ff @(posedge clk) begin
  if (rst)
    shift_reg <= 'b0;
  else if (en)
    shift_reg <= {D, shift_reg[WIDTH - 1 : 1]};
end

assign Q = shift_reg[0];

endmodule



module shift_reg_with_parellel_load #(
parameter WIDTH = 20
)(
input  logic                 clk,
input  logic                 rst,
input  logic                 we,
input  logic                 en,
input  logic [WIDTH - 1 : 0] D,

output logic                 Q
);

logic [WIDTH - 1 : 0] shift_reg;

always_ff @(posedge clk) begin
    if (rst)
        shift_reg <= 'b0;
    else if (we) 
        shift_reg <= D;
    else if (en)
        shift_reg <= {D[WIDTH -1], shift_reg[WIDTH - 1 : 1]};
end

assign Q = shift_reg[0];

endmodule
