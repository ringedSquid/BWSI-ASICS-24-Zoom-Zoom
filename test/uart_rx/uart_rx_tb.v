`include "uart_rx.v"
`timescale 1ns/1ps

module uart_rx_tb;
	//i/0 for uart
	reg clk;
	reg baud_clk;
	reg [12:0] baud_clk_counter;
	reg reset;
	reg rx;
	reg [12:0] speed;
	reg set_speed;

	wire actual_uart_inbound;
	wire [7:0] actual_data_received;
	
	//for testbench
	reg [31:0] vectornum;
	reg [31:0] errors;
	reg [23:0] testvectors [100000:0];

	//for waiting
	reg [31:0] bitcount;

	uart_rx rx_test (
		.clk(clk),
		.reset(reset),
		.rx(rx),
		.speed(speed),
		.set_speed(set_speed),
		.uart_inbound(actual_uart_inbound),
		.data_received(actual_data_received)
	);

	reg expected_uart_inbound;
	reg [7:0] expected_data_received;

	always begin
		clk = 1; #5;
		clk = 0; #5;
	end
	
	initial begin
		baud_clk = 0;
		baud_clk_counter = 0;
		//load in data
		$readmemb("uart_rx_tb.tv", testvectors, 0, 65536);	
		vectornum = 0;
		errors = 0;

		//reset wait
		bitcount = 0;

		//dump file
		$dumpfile("uart_rx_tb.vcd");
		$dumpvars(0, uart_rx_tb);
		

		//
		reset = 1; #27;
		reset = 0;
	end
	
	always @(posedge clk) begin
		if (baud_clk_counter >= 13'h1869) begin
			baud_clk_counter <= 0;
			baud_clk <= ~baud_clk;
		end else
			baud_clk_counter <= baud_clk_counter + 1;
	end

	always @(posedge baud_clk) begin
	        #1;	
		if (~reset && (bitcount === 0)) begin
			rx <= testvectors[vectornum][23];
			speed <= testvectors[vectornum][22:10];
			set_speed <= testvectors[vectornum][9];
			expected_uart_inbound <= testvectors[vectornum][8];
			expected_data_received <= testvectors[vectornum][7:0];
		end
		bitcount = bitcount + 1;
	end

	always @(negedge baud_clk) begin
		#1
		if (~reset) begin
			if (1) begin
				if (expected_uart_inbound != actual_uart_inbound || expected_data_received != actual_data_received) begin
					$display("ERROR: %d\tCASE: %d", errors, vectornum);
					$display("\tINPUTS:");
					$display("\t\rx: %h", rx);
					$display("\t\tspeed: %h", speed);
					$display("\t\tset_speed : %h", set_speed);
					$display("\tOUTPUTS:");
					$display("\t\tuart_inbound: EXPECTED: %h | ACTUAL %h", expected_uart_inbound, actual_uart_inbound);
					$display("\t\tdata_received  : EXPECTED: %h | ACTUAL %h", expected_data_received, actual_data_received);
					$display("------------------------------------------------");
					errors = errors + 1;
				end

				vectornum = vectornum + 1;

				if (testvectors[vectornum] === 24'bx) begin
					$display("%d tests completed with %d errors", vectornum, errors);
					$finish;		
				end
				bitcount = 0;
			end
		end
	end

endmodule

