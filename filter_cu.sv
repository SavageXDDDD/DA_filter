module filter_cu #(
parameter WORD_WIDTH = 16
)(
input  logic clk, 
input  logic rst,
input  logic en,
output logic filter_en,
output logic x_we,
output logic ts
);

logic [$clog2(WORD_WIDTH) - 1 : 0] counter;

always_ff @(posedge clk) begin 
  if (rst | (counter == WORD_WIDTH - 1))
    counter <= 'h0;
  else if (filter_en) 
    counter <= counter + 1;
end

assign ts = (counter == WORD_WIDTH - 1) ? 1 : 0;

enum logic
{
   IDLE = 1'b0,
   WORK = 1'b1
}
state, next_state;

always_ff @(posedge clk) begin
  if (rst)
    state <= IDLE;
  else 
    state <= next_state;
end

always_comb begin 
  next_state = state;
  case (state)
    IDLE : begin 
      filter_en <= 0;
      if (en) begin 
        x_we = 1;
        next_state = WORK;
      end else begin
        x_we = 0;
        next_state = IDLE; 
      end
    end 
    WORK : begin 
      x_we = 0;  
      if (~en) begin 
        next_state <= IDLE;
        filter_en <= 0;
      end else begin 
        next_state <= WORK; 
        filter_en <= 1;
      end
    end
  endcase
end


endmodule