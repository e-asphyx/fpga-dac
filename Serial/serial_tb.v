`timescale 1ns/100ps
module fir_serial_tb();

reg clk = 0;
always #1 clk = ~clk;


integer in, out, count, i;

reg [7:0] data_buf [0:1];
wire signed [15:0] data;
assign data = {data_buf[1], data_buf[0]};

wire signed [15:0] result;

reg sample_ready = 0;
wire rdy;

fir_serial fir(.clk(clk), .sample(data), .sample_ready(sample_ready), .out(result), .rdy(rdy));

initial begin
	$dumpvars(0, fir_serial_tb);

	in = $fopen("4kHz.raw", "r");
	if (!in) begin
		$finish;
	end

	out = $fopen("out.raw", "w");
	if (!out) begin
		$finish;
	end

	while (!$feof(in)) begin
		count = $fread(data_buf, in);
		if(count != 0) begin
			//$display("%d", data);
			sample_ready = 1;
			#2
			sample_ready = 0;
			#2

			i = 0;
			while (i < 8) begin
				@(posedge clk) begin
					if(rdy) begin						
						//$display("%d", result);
						count = $fputc(result[7:0], out);
						count = $fputc(result[15:8], out);
						i = i + 1;
					end
				end
			end

			#2;
		end
	end
	$fclose(out);
	$fclose(in);
	$finish;
end
endmodule