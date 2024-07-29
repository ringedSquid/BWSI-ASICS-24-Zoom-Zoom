module alu (
	input wire ai,
	input wire bi,
	input wire oe,
	input wire [15:0] a,
	input wire [15:0] b,
	output wire [15:0] out,
	output wire [6:0] flags,

	input wire [1:0] sel
);
	reg [15:0] buff;
	always @(*) begin
		if (
		case(sel)
			2'b00 : buff <= a + b;
			2'b01 : buff <= a - b;
			2'b10 : buff <= a * b;
			2'b11 : buff <= ~(a & b);
		endcase
		assign out = buff & {16*{oe}};

	end

endmodule 
