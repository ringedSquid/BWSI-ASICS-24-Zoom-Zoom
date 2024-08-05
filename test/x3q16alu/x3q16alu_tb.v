`include "x3q16alu.v"

module x3q16alu_tb;
	
	//i/0 for uart
	reg clk;
	reg [15:0] a, b, errors;
	reg [2:0] mode;
	
	//for testbench
	reg [31:0] vectornum;
	reg [52:0] testvectors [100000:0];

	wire [15:0] result;
	wire gaf, ef;

	reg [15:0] expected_result;
	reg expected_ef;
	reg expected_gaf;

	x3q16alu ALU (
		.a(a),
		.b(b),
		.mode(mode),
		
		.result(result),
		.equal_flag(ef),
		.greater_a_flag(gaf)
	);

	initial begin
		//load in data
		errors <= 16'b0;
		$readmemb("x3q16alu_tb.tv", testvectors, 0, 65536);	
		vectornum = 0;

		//dump file
		$dumpfile("x3q16alu_tb.vcd");
		$dumpvars(0, x3q16alu_tb);
	end

	always begin
		#30
		clk = 1; #5;
		clk = 0; #5;
	end
	

	always @(posedge clk) begin
		mode <= testvectors[vectornum][52:50];
		a <= testvectors[vectornum][49:34];
		b <= testvectors[vectornum][33:18];
		expected_result <= testvectors[vectornum][17:2];
		expected_gaf <= testvectors[vectornum][0];
		expected_ef <= testvectors[vectornum][1];
	end

	always @(negedge clk) begin
		if (expected_ef != ef) $display("ERROR, x3q16alu, equal flag, %d", vectornum+1);
		if (expected_gaf != gaf) $display("ERROR, x3q16alu, greater A flag, %d", vectornum+1);
		if (expected_result != result) $display("ERROR, x3q16alu, result, %d", vectornum+1);
		vectornum = vectornum + 1;

		if (vectornum == 100) $finish;
	end
endmodule
