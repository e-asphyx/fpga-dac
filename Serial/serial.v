`timescale 1ns/100ps
module fir_serial(clk, rst, wren, sample, out, rdy);

parameter rom_bits = 24;
parameter fp_bits = 22;
parameter rom_addr_bits = 9;
parameter bits = 16;

parameter buf_sz = 62;
parameter buf_sz_bits = 6;

localparam acc_bits = buf_sz_bits+bits+rom_bits;

// ----------------------------------
input clk;
input rst;
input signed [(bits-1):0] sample;
input wren;

output signed [(bits-1):0] out;
output rdy;

// ----------------------------------
// Stage 0
integer i;
reg [3:0] step;
reg [(buf_sz_bits-1):0] idx;
reg signed [(bits-1):0] buffer[0:(buf_sz-1)];

always @(posedge clk or posedge rst) begin
	if(rst) begin
		for (i = 0; i < buf_sz; i = i + 1) begin
			buffer[i] <= 'h0;
		end

		step <= 'h8;
		idx <= buf_sz;
		
	end else if(wren) begin
		buffer[0] <= sample;

		for (i = 1; i < buf_sz; i = i + 1) begin
			buffer[i] <= buffer[i - 1];
		end

		step <= 'h0;
		idx <= 'h0;

	end else if (step != 8) begin
		if (idx == buf_sz) begin
			step <= step + 1'b1;

			// Stop
			if(step != 7) begin
				idx <= 'h0;
			end
		end else begin
			idx <= idx + 1'b1;
		end
	end
end

// ----------------------------------
// Stage 1
reg idx_ok;
reg [(rom_addr_bits-1):0] tap;
reg signed [(bits-1):0] data;
reg stop;

always @(posedge clk or posedge rst) begin
	if(rst) begin
		idx_ok <= 1'b0;
		tap <= 'h0;
		data <= 'h0;
		stop <= 1'b1;
	end else begin	
		if(idx != buf_sz) begin
			tap <= (idx << 3) + step;
			data <= buffer[idx];
		end
		idx_ok <= idx != buf_sz;
		stop <= idx == buf_sz && step == 8;
	end
end

// ----------------------------------
// Stage 2
wire signed [(rom_bits-1):0] coef;
rom coef_rom(.clk(clk), .data(coef), .addr(tap)); // registered output ROM

reg signed [(bits-1):0] data1;
reg data_ok;
reg stop1;

// Wait for data registered
always @(posedge clk or posedge rst) begin
	if(rst) begin
		data_ok <= 1'b0;
		stop1 <= 1'b1;
		data1 <= 'h0;
	end else begin
		data_ok <= idx_ok;
		data1 <= data;
		stop1 <= stop;
	end
end

// ----------------------------------
// Stage 3
reg signed [(acc_bits-1):0] acc;

wire signed [(acc_bits-fp_bits-1):0] rounded;
assign rounded = (acc + (1 << (fp_bits-1)) >> fp_bits;

wire signed [(bits-1):0] result;
assign result = (rounded > 32767 ? 32767 : (rounded < -32768 ? -32768 : rounded));

reg signed [(bits-1):0] out;
reg rdy_strobe;

always @(posedge clk or posedge rst) begin
	if(rst) begin
		acc <= 'h0;
		out <= 'h0;
		rdy_strobe <= 'h0;

	end else begin		
		if(data_ok) begin
			acc <= acc + data1*coef;
			rdy_strobe <= 'b0;

		end else if(!stop1) begin
			acc <= 'h0;
			out <= result;
			rdy_strobe <= 'b1;

		end else begin
			rdy_strobe <= 'b0;
		end
	end
end

reg rdy;
always @(negedge clk) begin
	rdy <= rdy_strobe;
end

// ----------------------------------
initial begin
	for (i = 0; i < buf_sz; i = i + 1) begin
		buffer[i] <= 0;
	end

	step = 8;
	idx = buf_sz;
	idx_ok = 0;
	data_ok = 0;
	stop = 1;
	stop1 = 1;
	acc = 0;
	out = 0;
	rdy_strobe = 0;
end
endmodule