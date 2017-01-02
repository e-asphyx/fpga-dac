`timescale 1ns/100ps
module dither(clk, rst, wren, in, out);
parameter in_bits = 40;
parameter fp_bits = 22;
parameter out_bits = 16;

input clk;
input rst;
input wren;

input signed [(in_bits-1):0] in;
output signed [(out_bits-1):0] out;

wire [(fp_bits-1):0] rand_0;
wire [(fp_bits-1):0] rand_1;

generate
	genvar ig;

	for (ig = 0; ig < fp_bits; ig = ig + 1) begin: lfsr_0
		wire [31:0] lfsr_out;
		assign rand_0[ig] = lfsr_out[0];

		lfsr lfsr_inst(.clk(clk), .rst(rst), .out(lfsr_out));
		defparam lfsr_inst.seed = (('h91265b253c9185d5 >> ig) & 'hffffffff) ^ 'h9acf46de;
	end

	for (ig = 0; ig < fp_bits; ig = ig + 1) begin: lfsr_1
		wire [31:0] lfsr_out;
		assign rand_1[ig] = lfsr_out[0];

		lfsr lfsr_inst(.clk(clk), .rst(rst), .out(lfsr_out));
		defparam lfsr_inst.seed = (('ha6428e65c416edca >> ig) & 'hffffffff) ^ 'hf3f9ab98;
	end
endgenerate

reg signed [(fp_bits+2):0] sum;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		sum <= 'h0;
	end else begin
		sum <= rand_0 + rand_1 - (1 << fp_bits);
	end
end

//-----------------------------------------------------

/*
`define TAP0 $rtoi(2.033*(1 << fp_bits))
`define TAP1 $rtoi(-2.165*(1 << fp_bits))
`define TAP2 $rtoi(1.959*(1 << fp_bits))
`define TAP3 $rtoi(-1.590*(1 << fp_bits))
`define TAP4 $rtoi(0.6149*(1 << fp_bits))
*/

// 22 bits fp
`define TAP0 (8527020)
`define TAP1 (-9080668)
`define TAP2 (8216642)
`define TAP3 (-6668943)
`define TAP4 (2579078)

reg signed [(fp_bits+3):0] rand;
reg signed [(fp_bits+3):0] e [0:4];
reg signed [(fp_bits+3):0] prod [0:4];

// ------------------------------------
// Debug
wire signed [(fp_bits+3):0] e0;
wire signed [(fp_bits+3):0] e1;
wire signed [(fp_bits+3):0] e2;
wire signed [(fp_bits+3):0] e3;
wire signed [(fp_bits+3):0] e4;
assign e0 = e[0];
assign e1 = e[1];
assign e2 = e[2];
assign e3 = e[3];
assign e4 = e[4];

wire signed [(fp_bits+3):0] prod0;
wire signed [(fp_bits+3):0] prod1;
wire signed [(fp_bits+3):0] prod2;
wire signed [(fp_bits+3):0] prod3;
wire signed [(fp_bits+3):0] prod4;
assign prod0 = prod[0];
assign prod1 = prod[1];
assign prod2 = prod[2];
assign prod3 = prod[3];
assign prod4 = prod[4];
// ------------------------------------

reg signed [(in_bits-1):0] sample;
reg signed [(in_bits-1):0] xp;
reg signed [(in_bits-1):0] xe;

wire signed [(in_bits-1):0] rounded;
assign rounded = (xp + (1 << (fp_bits-1))) & (~((1 << (fp_bits)) - 1));

reg [1:0] state;

reg signed [(out_bits-1):0] out;

integer i;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		for (i = 0; i < 5; i = i + 1) begin
			e[i] <= 'h0;
			prod[i] <= 'h0;
		end
		rand <= 'h0;
		sample <= 'h0;
		xp <= 'h0;
		xe <= 'h0;
		state <= 'h0;

	end else begin
		case(state)
			0: if (wren) begin
				prod[0] <= ({{(fp_bits+3){1'b0}}, e[0]} * `TAP0) >> fp_bits;
				prod[1] <= ({{(fp_bits+3){1'b0}}, e[1]} * `TAP1) >> fp_bits;
				prod[2] <= ({{(fp_bits+3){1'b0}}, e[2]} * `TAP2) >> fp_bits;
				prod[3] <= ({{(fp_bits+3){1'b0}}, e[3]} * `TAP3) >> fp_bits;
				prod[4] <= ({{(fp_bits+3){1'b0}}, e[4]} * `TAP4) >> fp_bits;
				sample <= in;
				rand <= sum;
				state <= 1;
			end

			1: begin
				xe <= sample + prod[0] + prod[1] + prod[2] + prod[3] + prod[4];
				state <= 2;
			end

			2: begin
				xp <= xe + rand;
				state <= 3;
			end

			3: begin
				out <= rounded >> fp_bits;
    			e[0] <= xe - rounded;
				e[1] <= e[0];			
				e[2] <= e[1];				
				e[3] <= e[2];				
				e[4] <= e[3];
				state <= 0;				
			end
		endcase
	end
end

//-----------------------------------------------------
initial begin
	for (i = 0; i < 5; i = i + 1) begin
		e[i] = 'h0;
		prod[i] = 'h0;
	end
	rand = 'h0;
	sample = 'h0;
	xp = 'h0;
	xe = 'h0;
	state = 'h0;
	sum = 'h0;
end

endmodule