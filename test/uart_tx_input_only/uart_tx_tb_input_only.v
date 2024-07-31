`include "uart_tx.v"

module uart_tx_tb_input_only;
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
	reg [17:0] testvectors [100000:0];

	//for waiting
	reg [31:0] bitcount;

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
	
	initial begin
		//load in data
		$readmemb("uart_tx_tb.tv", testvectors, 0, 65536);	
		vectornum = 0;

		//reset wait
		bitcount = 0;

		//dump file
		$dumpfile("uart_tx_tb_input_only.vcd");
		$dumpvars(0, uart_tx_tb_input_only);
		

		//reset
		reset = 1; #27;
		reset = 0;
	end

	always @(posedge clk) begin
	        #1;	
		if (~reset && (bitcount === 0)) begin
			data <= testvectors[vectornum][17:2];
			send <= testvectors[vectornum][1];
			set <= testvectors[vectornum][0];
		end
		bitcount = bitcount + 1;
	end

	always @(negedge clk) begin
		#1
		if (~reset) begin
			vectornum = vectornum + 1;
			if (testvectors[vectornum] === 18'bx) begin
				$display("%d tests completed", vectornum);
				$finish;		
			end
			bitcount = 0;
		end
	end

endmodule

