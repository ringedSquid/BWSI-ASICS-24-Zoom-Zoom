`include "memory_control.v"

module memory_control_tb;
	reg clk;
	reg reset;
	reg [15:0] request_address;
	reg request_type;
	reg request;
	reg [15:0] data_out;

	wire [15:0] memory_in;
	wire memory_ready;
	wire write_complete;

	reg [31:0] vectornum, errors;
	reg [63:0] testvectors [100000:0];

	reg [15:0] expected_memory_in;
	reg expected_memory_ready;
	reg expected_write_complete;

	memory_control mc (
		.clk(clk),
		.reset(reset),
		.request_address(request_address),
		.request_type(request_type),
		.request(request),
		.data_out(data_out),
		.memory_in(memory_in),
		.memory_ready(memory_ready),
		.write_complete(write_complete)
	);


	initial begin
		$readmemh("memory_control_tb.tv", testvectors, 0, 65536);
		vectornum = 0;
		errors = 0;
		reset = 1; #27;
		reset = 0;
	end

	always begin
		clk = 1; #5;
		clk = 0; #5;
	end

	always @(posedge clk) begin
		if (~reset) begin
			#1;
			request_address 	<= testvectors[vectornum][63:48];
			request_type     	<= testvectors[vectornum][44];
			request			<= testvectors[vectornum][40];
			data_out		<= testvectors[vectornum][39:24];
			expected_memory_in	<= testvectors[vectornum][23:8];
			expected_memory_ready	<= testvectors[vectornum][4];
			expected_write_complete	<= testvectors[vectornum][0];
		end
	end

	always @(negedge clk) begin
		if (~reset) begin
			if (
				(expected_memory_in !== memory_in) ||
				(expected_memory_ready !== memory_ready) ||
				(expected_write_complete !== write_complete)
			)
			begin
				$display("ERROR:%d\tCASE:%d", errors, vectornum);
				$display("\tInputs:");
				$display("\t\trequest_addr:\t%h", request_address);
				$display("\t\trequest_type:\t%h", request_type);
				$display("\t\trequest:\t%h", request);
				$display("\t\tdata_out:\t%h", data_out);
				$display();
				$display("\tOutputs:");
				$display("\t\tmemory_in:\tExpected:\t%h\tActual:\t%h", expected_memory_in, memory_in);
				$display("\t\tmemory_ready:\tExpected:\t%h\tActual:\t%h", expected_memory_ready, memory_ready);
				$display("\t\twrite_complete:\tExpected:\t%h\tActual:\t%h", expected_write_complete, write_complete);
				$display("");
				errors = errors + 1;
			end

			vectornum = vectornum + 1;
			if (testvectors[vectornum] === 64'bx) begin
				$display("COMPLETE:");
				$display("\t%d tests completed with %d errors!", vectornum, errors);
				$finish;
			end
		end
	end
endmodule
