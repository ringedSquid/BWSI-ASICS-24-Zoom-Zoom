`include "x3q16.v"

module x3q16_tb;
	reg clk;
	reg reset;
	reg [15:0] memory_in;
	reg memory_ready;
	reg write_complete;
	reg uart_inbound;
	reg memory_critical;

	wire [15:0] request_address;
	wire request_type;
	wire request;
	wire [15:0] data_out;
	wire tx;

	//For the sim
	reg [15:0] check_address;
	reg [15:0] expected_value;

	reg [31:0] testvectors [65535:0];
	reg [31:0] vectornum;
	reg [31:0] errors;
	
	reg [1:0] clockcount;

	/*
	* 1 -> running program
	* 0 -> checking memory
	*/
	reg [1:0] state;
	reg req_hold;

	reg [15:0] ram [65535:0];
 
	x3q16 cpu (
		.clk(clk),
		.reset(reset),
		.memory_in(memory_in),
		.memory_ready(memory_ready),
		.write_complete(write_complete),
		.uart_inbound(uart_inbound),
		.memory_critical(memory_critical),
		.request_address(request_address),
		.request_type(request_type),
		.request(request),
		.data_out(data_out),
		.tx(tx)
	);

	/*
	* A program loaded into memory for the CPU.
	* Then the cpu runs it and spits out some answer into memory,
	* the testbench then checks those addresses to see if it passes the
	* test
 	*/

	always begin
		clk = 1; #5;
		clk = 0; #5;
	end

	initial begin
		//load ram
		$readmemh("program.bin", ram, 0, 65535);
		$readmemh("program_checks.tv", testvectors, 0, 65535);
		vectornum = 0;
		errors = 0;
		state = 1;

		$dumpfile("x3q16_tb.vcd");
		$dumpvars(0, x3q16_tb);

		memory_ready = 0;
		write_complete = 1;
		uart_inbound = 0;
		memory_critical = 0;

		clockcount = 0;

		reset = 1; #27;
		reset = 0;
	end

	always @(posedge clk) begin
		if (~reset) begin
			if (state === 1) begin //Run program
				if (request) begin
					req_hold <= 1;
				end else begin
					req_hold <= 0;
				end

				if (memory_ready) begin
					memory_ready <= 0;
				end

				if (write_complete) begin
					write_complete <= 1;
				end

				if (request && request_type) begin
					//$display("WREQ: %h: %h, %b", request_address, ram[request_address], ram[request_address]);
					ram[request_address] <= data_out; 
					write_complete <= 1;
				end

				if (req_hold) begin
					if (!request_type) begin
						//$display("RREQ: %h: %h, %b", request_address, ram[request_address], ram[request_address]);
						memory_in <= ram[request_address];
						memory_ready <= 1;

						if (request_address === 16'hffff) begin
							state <= 0;
						end

					end
				end
			end else if (state === 2) begin //Check memory addresses (well load them)
				check_address <= testvectors[vectornum][31:16];
				expected_value <= testvectors[vectornum][15:0];
			end
		end
	end

	always @(negedge clk) begin
		if (~reset) begin
			if (state === 2) begin
				if (expected_value !== ram[check_address]) begin
					$display("ERROR: %h\t CASE: %h", errors, vectornum);
					$display("\tADDR: %h", check_address);
					$display("\t\tEXPECTED: %h\tACTUAL: %h", expected_value, ram[check_address]);
					$display("---------------------------------------------");
					errors = errors + 1;
				end
				vectornum = vectornum + 1;
				
				if (testvectors[vectornum] === 32'bx) begin
					$display("SUCCESS");
					$display("%d addresses checked with %d mismatches", vectornum, errors);
					$finish;
				end
			end
			else if (state === 0) begin
				state <= 2;
			end
		end
	end

endmodule
