`timescale 1ns/100ps
module lfsr(clk, rst, out);
parameter bits = 32;
parameter seed = 'hed02c8a9;
parameter mask = 'h46000000;
input clk;
input rst;
output [(bits-1):0] out;
reg [(bits-1):0] out;

wire [(bits-2):0] shifted;
assign shifted = out[(bits-1):1] ^ ({(bits-1){out[0]}} & mask);

always @(posedge clk or posedge rst) begin
	if (rst) begin
		out <= seed;
	end else begin
		out[(bits-1):0] <= {out[0], shifted};
	end
end

initial begin
	out = seed;
end

endmodule