`timescale 1ns/100ps
module lfsr_tb();
	reg clk = 0;
	always #1 clk = ~clk;

	wire [31:0] out;

	generate
		genvar i;
		for (i = 0; i < 32; i = i + 1) begin: lfsr_instance
			wire [31:0] lfsr_out;
			assign out[i] = lfsr_out[0];

			lfsr lfsr_inst(.clk(clk), .rst(1'b0), .out(lfsr_out));
			defparam lfsr_inst.seed = (('h91265b253c9185d5 >> i) & 'hffffffff) ^ 'h9acf46de;
		end
	endgenerate

	initial begin
		$dumpvars(0, lfsr_tb);
		#50000 $finish;
	end
endmodule
