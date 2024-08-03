`include "x3q16alu.v"
module x3q16alu_tb;
	//Declare inputs to ALU
	reg [15:0] a;
	reg [15:0] b;
	reg [2:0] mode;

	//Declare outputs of ALU
	wire [15:0] result;
	wire equal_flag;
	wire greater_a_flag;

	//Outputs for checking
	reg [15:0] expected_result;
	reg expected_equal_flag;
	reg expected_greater_a_flag;

	//Testvectors
	reg [31:0] vectornum, errors;
	reg [52:0] testvectors[100000:0];
	
	reg clk;
	reg reset;

	//Init ALU
	x3q16alu alu (
		.a(a),
		.b(b),
		.mode(mode),
		.result(result),
		.equal_flag(equal_flag),
		.greater_a_flag(greater_a_flag)
	);

	always begin
		clk = 1;
		#5;
		clk = 0;
		#5;
	end

	initial begin
		$readmemb("x3q16alu_tb.tv", testvectors);
		vectornum = 0; 
		errors = 0;
		//reset wait
		reset = 1; 
		#27;
		reset = 0;
	end

	always @(posedge clk) begin
		//yeah idk fuck formatting
		#1;
		{
			a, b, mode, 
			expected_result, 
			expected_equal_flag, 
			expected_greater_a_flag
		} = testvectors[vectornum];
	end

	always @(negedge clk) 
		if (~reset)
		begin
			if (
				(result !== expected_result) || 
				(equal_flag !== expected_equal_flag) ||
				(greater_a_flag !== expected_greater_a_flag)
			)
			begin
				$display("Error: Inputs: a = %b, b = %b, mode = %b", a, b, mode);
				$display("       Outputs: result = %b, ef = %b, gf = %b", result, equal_flag, greater_a_flag);
				$display("	 Expected Out: result = %b, ef = %b, gf = %b", expected_result, expected_equal_flag, expected_greater_a_flag);
				errors = errors + 1;
			end
			
			vectornum = vectornum + 1;
			if (testvectors[vectornum] === 53'bx) begin
				$display("%d tests completed with %d errors", vectornum, errors);
				$finish;
			end
		end


endmodule
