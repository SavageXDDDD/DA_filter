module ring_oscillator (
input en,
output out
);

wire [3 : 0] s;

not u0(s[1], s[0]);
not u2(s[2], s[1]);
not u1(s[3], s[2]);

and u4(s[0], s[3], en);

assign out = s[0];

endmodule