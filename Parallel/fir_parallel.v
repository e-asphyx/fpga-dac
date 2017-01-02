`timescale 1ns/100ps
module fir_parallel(clk, sample, sample_ready, out);

parameter coef_bits = 24;
parameter fp_bits = 22;
parameter bits = 16;

parameter buf_sz = 62;
parameter buf_sz_bits = 6;

localparam mul_bits = bits+coef_bits;
localparam acc_bits = buf_sz_bits+bits+coef_bits;

// ----------------------------------
input clk;
input signed [(bits-1):0] sample;
input sample_ready;

output signed [(bits-1):0] out;

// ----------------------------------
// Stage 0
integer i;
reg signed [(bits-1):0] buffer[0:(buf_sz-1)];

always @(posedge clk) begin
	if(sample_ready) begin
		buffer[0] <= sample;

		for (i = 1; i < buf_sz; i = i + 1) begin
			buffer[i] <= buffer[i - 1];
		end
	end
end

reg signed [(mul_bits-1):0] mul_0_0;
reg signed [(mul_bits-1):0] mul_0_1;
reg signed [(mul_bits-1):0] mul_0_2;
reg signed [(mul_bits-1):0] mul_0_3;
reg signed [(mul_bits-1):0] mul_0_4;
reg signed [(mul_bits-1):0] mul_0_5;
reg signed [(mul_bits-1):0] mul_0_6;
reg signed [(mul_bits-1):0] mul_0_7;
reg signed [(mul_bits-1):0] mul_0_8;
reg signed [(mul_bits-1):0] mul_0_9;
reg signed [(mul_bits-1):0] mul_0_10;
reg signed [(mul_bits-1):0] mul_0_11;
reg signed [(mul_bits-1):0] mul_0_12;
reg signed [(mul_bits-1):0] mul_0_13;
reg signed [(mul_bits-1):0] mul_0_14;
reg signed [(mul_bits-1):0] mul_0_15;
reg signed [(mul_bits-1):0] mul_0_16;
reg signed [(mul_bits-1):0] mul_0_17;
reg signed [(mul_bits-1):0] mul_0_18;
reg signed [(mul_bits-1):0] mul_0_19;
reg signed [(mul_bits-1):0] mul_0_20;
reg signed [(mul_bits-1):0] mul_0_21;
reg signed [(mul_bits-1):0] mul_0_22;
reg signed [(mul_bits-1):0] mul_0_23;
reg signed [(mul_bits-1):0] mul_0_24;
reg signed [(mul_bits-1):0] mul_0_25;
reg signed [(mul_bits-1):0] mul_0_26;
reg signed [(mul_bits-1):0] mul_0_27;
reg signed [(mul_bits-1):0] mul_0_28;
reg signed [(mul_bits-1):0] mul_0_29;
reg signed [(mul_bits-1):0] mul_0_30;
reg signed [(mul_bits-1):0] mul_0_31;
reg signed [(mul_bits-1):0] mul_0_32;
reg signed [(mul_bits-1):0] mul_0_33;
reg signed [(mul_bits-1):0] mul_0_34;
reg signed [(mul_bits-1):0] mul_0_35;
reg signed [(mul_bits-1):0] mul_0_36;
reg signed [(mul_bits-1):0] mul_0_37;
reg signed [(mul_bits-1):0] mul_0_38;
reg signed [(mul_bits-1):0] mul_0_39;
reg signed [(mul_bits-1):0] mul_0_40;
reg signed [(mul_bits-1):0] mul_0_41;
reg signed [(mul_bits-1):0] mul_0_42;
reg signed [(mul_bits-1):0] mul_0_43;
reg signed [(mul_bits-1):0] mul_0_44;
reg signed [(mul_bits-1):0] mul_0_45;
reg signed [(mul_bits-1):0] mul_0_46;
reg signed [(mul_bits-1):0] mul_0_47;
reg signed [(mul_bits-1):0] mul_0_48;
reg signed [(mul_bits-1):0] mul_0_49;
reg signed [(mul_bits-1):0] mul_0_50;
reg signed [(mul_bits-1):0] mul_0_51;
reg signed [(mul_bits-1):0] mul_0_52;
reg signed [(mul_bits-1):0] mul_0_53;
reg signed [(mul_bits-1):0] mul_0_54;
reg signed [(mul_bits-1):0] mul_0_55;
reg signed [(mul_bits-1):0] mul_0_56;
reg signed [(mul_bits-1):0] mul_0_57;
reg signed [(mul_bits-1):0] mul_0_58;
reg signed [(mul_bits-1):0] mul_0_59;
reg signed [(mul_bits-1):0] mul_0_60;
reg signed [(mul_bits-1):0] mul_0_61;

always @(posedge clk) begin
	mul_0_0 <= buffer[0] * (663);
	mul_0_1 <= buffer[1] * (-492);
	mul_0_2 <= buffer[2] * (651);
	mul_0_3 <= buffer[3] * (-1101);
	mul_0_4 <= buffer[4] * (1577);
	mul_0_5 <= buffer[5] * (-2280);
	mul_0_6 <= buffer[6] * (3145);
	mul_0_7 <= buffer[7] * (-4268);
	mul_0_8 <= buffer[8] * (5658);
	mul_0_9 <= buffer[9] * (-7382);
	mul_0_10 <= buffer[10] * (9479);
	mul_0_11 <= buffer[11] * (-12015);
	mul_0_12 <= buffer[12] * (15049);
	mul_0_13 <= buffer[13] * (-18656);
	mul_0_14 <= buffer[14] * (22917);
	mul_0_15 <= buffer[15] * (-27927);
	mul_0_16 <= buffer[16] * (33799);
	mul_0_17 <= buffer[17] * (-40672);
	mul_0_18 <= buffer[18] * (48720);
	mul_0_19 <= buffer[19] * (-58169);
	mul_0_20 <= buffer[20] * (69326);
	mul_0_21 <= buffer[21] * (-82618);
	mul_0_22 <= buffer[22] * (98667);
	mul_0_23 <= buffer[23] * (-118419);
	mul_0_24 <= buffer[24] * (143393);
	mul_0_25 <= buffer[25] * (-176185);
	mul_0_26 <= buffer[26] * (221623);
	mul_0_27 <= buffer[27] * (-289806);
	mul_0_28 <= buffer[28] * (405905);
	mul_0_29 <= buffer[29] * (-654846);
	mul_0_30 <= buffer[30] * (1615898);
	mul_0_31 <= buffer[31] * (3546834);
	mul_0_32 <= buffer[32] * (-836171);
	mul_0_33 <= buffer[33] * (466342);
	mul_0_34 <= buffer[34] * (-317461);
	mul_0_35 <= buffer[35] * (235949);
	mul_0_36 <= buffer[36] * (-183886);
	mul_0_37 <= buffer[37] * (147400);
	mul_0_38 <= buffer[38] * (-120220);
	mul_0_39 <= buffer[39] * (99100);
	mul_0_40 <= buffer[40] * (-82192);
	mul_0_41 <= buffer[41] * (68369);
	mul_0_42 <= buffer[42] * (-56898);
	mul_0_43 <= buffer[43] * (47285);
	mul_0_44 <= buffer[44] * (-39179);
	mul_0_45 <= buffer[45] * (32319);
	mul_0_46 <= buffer[46] * (-26511);
	mul_0_47 <= buffer[47] * (21598);
	mul_0_48 <= buffer[48] * (-17455);
	mul_0_49 <= buffer[49] * (13977);
	mul_0_50 <= buffer[50] * (-11076);
	mul_0_51 <= buffer[51] * (8671);
	mul_0_52 <= buffer[52] * (-6698);
	mul_0_53 <= buffer[53] * (5092);
	mul_0_54 <= buffer[54] * (-3807);
	mul_0_55 <= buffer[55] * (2779);
	mul_0_56 <= buffer[56] * (-1994);
	mul_0_57 <= buffer[57] * (1365);
	mul_0_58 <= buffer[58] * (-941);
	mul_0_59 <= buffer[59] * (551);
	mul_0_60 <= buffer[60] * (-412);
	mul_0_61 <= buffer[61] * (130);
end

// Stage 0
reg signed [(acc_bits-1):0] sum_stage1_0;
reg signed [(acc_bits-1):0] sum_stage1_1;
reg signed [(acc_bits-1):0] sum_stage1_2;
reg signed [(acc_bits-1):0] sum_stage1_3;
reg signed [(acc_bits-1):0] sum_stage1_4;
reg signed [(acc_bits-1):0] sum_stage1_5;
reg signed [(acc_bits-1):0] sum_stage1_6;
reg signed [(acc_bits-1):0] sum_stage1_7;
reg signed [(acc_bits-1):0] sum_stage1_8;
reg signed [(acc_bits-1):0] sum_stage1_9;
reg signed [(acc_bits-1):0] sum_stage1_10;
reg signed [(acc_bits-1):0] sum_stage1_11;
reg signed [(acc_bits-1):0] sum_stage1_12;
reg signed [(acc_bits-1):0] sum_stage1_13;
reg signed [(acc_bits-1):0] sum_stage1_14;
reg signed [(acc_bits-1):0] sum_stage1_15;
reg signed [(acc_bits-1):0] sum_stage1_16;
reg signed [(acc_bits-1):0] sum_stage1_17;
reg signed [(acc_bits-1):0] sum_stage1_18;
reg signed [(acc_bits-1):0] sum_stage1_19;
reg signed [(acc_bits-1):0] sum_stage1_20;
reg signed [(acc_bits-1):0] sum_stage1_21;
reg signed [(acc_bits-1):0] sum_stage1_22;
reg signed [(acc_bits-1):0] sum_stage1_23;
reg signed [(acc_bits-1):0] sum_stage1_24;
reg signed [(acc_bits-1):0] sum_stage1_25;
reg signed [(acc_bits-1):0] sum_stage1_26;
reg signed [(acc_bits-1):0] sum_stage1_27;
reg signed [(acc_bits-1):0] sum_stage1_28;
reg signed [(acc_bits-1):0] sum_stage1_29;
reg signed [(acc_bits-1):0] sum_stage1_30;

always @(posedge clk) begin
	sum_stage1_0 <= mul_0_0 + mul_0_1;
	sum_stage1_1 <= mul_0_2 + mul_0_3;
	sum_stage1_2 <= mul_0_4 + mul_0_5;
	sum_stage1_3 <= mul_0_6 + mul_0_7;
	sum_stage1_4 <= mul_0_8 + mul_0_9;
	sum_stage1_5 <= mul_0_10 + mul_0_11;
	sum_stage1_6 <= mul_0_12 + mul_0_13;
	sum_stage1_7 <= mul_0_14 + mul_0_15;
	sum_stage1_8 <= mul_0_16 + mul_0_17;
	sum_stage1_9 <= mul_0_18 + mul_0_19;
	sum_stage1_10 <= mul_0_20 + mul_0_21;
	sum_stage1_11 <= mul_0_22 + mul_0_23;
	sum_stage1_12 <= mul_0_24 + mul_0_25;
	sum_stage1_13 <= mul_0_26 + mul_0_27;
	sum_stage1_14 <= mul_0_28 + mul_0_29;
	sum_stage1_15 <= mul_0_30 + mul_0_31;
	sum_stage1_16 <= mul_0_32 + mul_0_33;
	sum_stage1_17 <= mul_0_34 + mul_0_35;
	sum_stage1_18 <= mul_0_36 + mul_0_37;
	sum_stage1_19 <= mul_0_38 + mul_0_39;
	sum_stage1_20 <= mul_0_40 + mul_0_41;
	sum_stage1_21 <= mul_0_42 + mul_0_43;
	sum_stage1_22 <= mul_0_44 + mul_0_45;
	sum_stage1_23 <= mul_0_46 + mul_0_47;
	sum_stage1_24 <= mul_0_48 + mul_0_49;
	sum_stage1_25 <= mul_0_50 + mul_0_51;
	sum_stage1_26 <= mul_0_52 + mul_0_53;
	sum_stage1_27 <= mul_0_54 + mul_0_55;
	sum_stage1_28 <= mul_0_56 + mul_0_57;
	sum_stage1_29 <= mul_0_58 + mul_0_59;
	sum_stage1_30 <= mul_0_60 + mul_0_61;
end

// Stage 1
reg signed [(acc_bits-1):0] sum_stage2_0;
reg signed [(acc_bits-1):0] sum_stage2_1;
reg signed [(acc_bits-1):0] sum_stage2_2;
reg signed [(acc_bits-1):0] sum_stage2_3;
reg signed [(acc_bits-1):0] sum_stage2_4;
reg signed [(acc_bits-1):0] sum_stage2_5;
reg signed [(acc_bits-1):0] sum_stage2_6;
reg signed [(acc_bits-1):0] sum_stage2_7;
reg signed [(acc_bits-1):0] sum_stage2_8;
reg signed [(acc_bits-1):0] sum_stage2_9;
reg signed [(acc_bits-1):0] sum_stage2_10;
reg signed [(acc_bits-1):0] sum_stage2_11;
reg signed [(acc_bits-1):0] sum_stage2_12;
reg signed [(acc_bits-1):0] sum_stage2_13;
reg signed [(acc_bits-1):0] sum_stage2_14;
reg signed [(acc_bits-1):0] sum_stage2_15;

always @(posedge clk) begin
	sum_stage2_0 <= sum_stage1_0 + sum_stage1_1;
	sum_stage2_1 <= sum_stage1_2 + sum_stage1_3;
	sum_stage2_2 <= sum_stage1_4 + sum_stage1_5;
	sum_stage2_3 <= sum_stage1_6 + sum_stage1_7;
	sum_stage2_4 <= sum_stage1_8 + sum_stage1_9;
	sum_stage2_5 <= sum_stage1_10 + sum_stage1_11;
	sum_stage2_6 <= sum_stage1_12 + sum_stage1_13;
	sum_stage2_7 <= sum_stage1_14 + sum_stage1_15;
	sum_stage2_8 <= sum_stage1_16 + sum_stage1_17;
	sum_stage2_9 <= sum_stage1_18 + sum_stage1_19;
	sum_stage2_10 <= sum_stage1_20 + sum_stage1_21;
	sum_stage2_11 <= sum_stage1_22 + sum_stage1_23;
	sum_stage2_12 <= sum_stage1_24 + sum_stage1_25;
	sum_stage2_13 <= sum_stage1_26 + sum_stage1_27;
	sum_stage2_14 <= sum_stage1_28 + sum_stage1_29;
	sum_stage2_15 <= sum_stage1_30;
end

// Stage 2
reg signed [(acc_bits-1):0] sum_stage3_0;
reg signed [(acc_bits-1):0] sum_stage3_1;
reg signed [(acc_bits-1):0] sum_stage3_2;
reg signed [(acc_bits-1):0] sum_stage3_3;
reg signed [(acc_bits-1):0] sum_stage3_4;
reg signed [(acc_bits-1):0] sum_stage3_5;
reg signed [(acc_bits-1):0] sum_stage3_6;
reg signed [(acc_bits-1):0] sum_stage3_7;

always @(posedge clk) begin
	sum_stage3_0 <= sum_stage2_0 + sum_stage2_1;
	sum_stage3_1 <= sum_stage2_2 + sum_stage2_3;
	sum_stage3_2 <= sum_stage2_4 + sum_stage2_5;
	sum_stage3_3 <= sum_stage2_6 + sum_stage2_7;
	sum_stage3_4 <= sum_stage2_8 + sum_stage2_9;
	sum_stage3_5 <= sum_stage2_10 + sum_stage2_11;
	sum_stage3_6 <= sum_stage2_12 + sum_stage2_13;
	sum_stage3_7 <= sum_stage2_14 + sum_stage2_15;
end

// Stage 3
reg signed [(acc_bits-1):0] sum_stage4_0;
reg signed [(acc_bits-1):0] sum_stage4_1;
reg signed [(acc_bits-1):0] sum_stage4_2;
reg signed [(acc_bits-1):0] sum_stage4_3;

always @(posedge clk) begin
	sum_stage4_0 <= sum_stage3_0 + sum_stage3_1;
	sum_stage4_1 <= sum_stage3_2 + sum_stage3_3;
	sum_stage4_2 <= sum_stage3_4 + sum_stage3_5;
	sum_stage4_3 <= sum_stage3_6 + sum_stage3_7;
end

// Stage 4
reg signed [(acc_bits-1):0] sum_stage5_0;
reg signed [(acc_bits-1):0] sum_stage5_1;

always @(posedge clk) begin
	sum_stage5_0 <= sum_stage4_0 + sum_stage4_1;
	sum_stage5_1 <= sum_stage4_2 + sum_stage4_3;
end

// Stage 5
reg signed [(acc_bits-1):0] sum_stage6_0;

always @(posedge clk) begin
	sum_stage6_0 <= sum_stage5_0 + sum_stage5_1;
end

// Stage 6
wire signed [(acc_bits-1):0] additive;
assign additive = sum_stage6_0 >= 0 ? (1 << (fp_bits-1)) : -(1 << (fp_bits-1));

wire signed [(acc_bits-fp_bits-1):0] rounded;
assign rounded = (sum_stage6_0 + additive) >> fp_bits;

wire signed [(bits-1):0] result;
assign result = (rounded > 32767 ? 32767 : (rounded < -32768 ? -32768 : rounded));

reg signed [(bits-1):0] out;

always @(posedge clk) begin
	out <= result;
end

endmodule