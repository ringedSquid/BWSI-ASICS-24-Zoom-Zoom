`include "uart_tx.v"

module uart_tx_tb;
	//i/0 for uart
	reg clk;
	reg reset;
	reg [15:0] data;
	reg send;
	reg set;

	wire tx;
	wire busy;
	
	//for testbench
	reg [31:0] vectornum;
	reg [31:0] errors;
	reg [19:0] testvectors [100000:0];

	//for waiting
	reg [31:0] bitcount;

	reg expected_busy;
	reg expected_tx;

	reg mismatch_busy;
	reg mismatch_tx;

	uart_tx tx_test (
		.clk(clk),
		.reset(reset),
		.data(data),
		.send(send),
		.set(set),
		.busy(busy),
		.tx_reg(tx)
	);

	always begin
		clk = 1; #5;
		clk = 0; #5;
	end
	
	//3125

	initial begin
		//load in data
		$readmemb("uart_tx_tb.tv", testvectors, 0, 65536);	
		vectornum = 0;
		errors = 0;

		//reset wait
		bitcount = 0;

		//dump file
		$dumpfile("uart_tx_tb.vcd");
		$dumpvars(0, uart_tx_tb);
		

		//
		reset = 1; #27;
		reset = 0;
	end

	always @(posedge clk) begin
	        #1;	
		if (~reset && (bitcount === 0)) begin
			data <= testvectors[vectornum][19:4];
			send <= testvectors[vectornum][3];
			set <= testvectors[vectornum][2];
			expected_busy <= testvectors[vectornum][1];
			expected_tx <= testvectors[vectornum][0];
		end
		bitcount = bitcount + 1;
	end

	always @(negedge clk) begin
		#1
		if (~reset) begin
			if (1) begin
				mismatch_busy <= expected_busy != busy;
				mismatch_tx <= expected_tx != tx;
				if (mismatch_busy || mismatch_tx) begin
					$display("ERROR: %d\tCASE: %d", errors, vectornum);
					$display("\tINPUTS:");
					$display("\t\tdata: %h", data);
					$display("\t\tsend: %h", send);
					$display("\t\tset : %h", set);
					$display("\tOUTPUTS:");
					$display("\t\tbusy: EXPECTED: %h | ACTUAL %h", expected_busy, busy);
					$display("\t\ttx  : EXPECTED: %h | ACTUAL %h", expected_tx, tx);
					$display("------------------------------------------------");
					errors = errors + 1;
				end

				vectornum = vectornum + 1;

				if (testvectors[vectornum] === 20'bx) begin
					$display("%d tests completed with %d errors", vectornum, errors);
					$finish;		
				end
				bitcount = 0;
			end
		end
	end

endmodule

