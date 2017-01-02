`timescale 1ns/100ps
module dither_tb();

reg clk = 0;
always #1 clk = ~clk;

reg signed [39:0] in;
wire signed [15:0] out;
reg wren = 0;

dither dither_inst(.clk(clk), .rst(1'b0), .wren(wren), .in(in), .out(out));

integer i, of, c;
initial begin
	$dumpvars(0, dither_tb);

	of = $fopen("out.raw", "w");
	if (!of) begin
		$finish;
	end

	in = 0;
	#4;
	for (i = 0; i < 441000; i = i + 1) begin
		wren = 1;
		#2 wren = 0;
		#6;
		c = $fputc(out[7:0], of);
		c = $fputc(out[15:8], of);
	end

	$fclose(of);

	$finish;
end
endmodule