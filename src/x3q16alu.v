module x3q16alu (
		input [15:0] a,
		input [15:0] b,
		input [2:0] mode,
		
		output reg [15:0] result,
		output reg equal_flag,
		output reg greater_a_flag
	);
	wire [15:0] sum;
	wire [15:0] sub;
	wire [8:0] mult;
	wire [7:0] mult_a, mult_b;
	
	assign sum = a + b;
	assign sub = a + ~b + 16'h0001;
	assign mult_a = a[7:0];
	assign mult_b = b[7:0];
	assign mult = mult_a * mult_b;
	
	always @(*) begin
		case (mode)
			3'b000: result = sum;
			3'b001: result = sub;
			3'b010: result = {7'b0, mult};
			3'b011: result = ~(a & b);
			3'b100: result = a << 1;
			3'b101: result = a >> 1;
			default: result = 16'h0000;
		endcase

		equal_flag = sub == 16'h0000;
		greater_a_flag = (~(sub == 16'h0000)) & ((b[15] & ~a[15]) | (a[15] & b[15] & ~sub[15]) | (~a[15] & ~b[15] & ~sub[15]));
	end
endmodule
