`include "uart_rx.v"

module uart_rx_tb;
	
	//i/0 for uart
	reg clk, reset;
	
	//for testbench
	reg [31:0] vectornum;
	reg [23:0] testvectors [100000:0];

    reg rx, set;
    reg [12:0] speed;

    reg inbound_expected;
    wire inbound;

    reg [7:0] data_expected;
    wire [7:0] data;

	uart_rx r (
		.clk(clk),
		.reset(reset),
		.rx(rx),
		.speed(speed),
		.set_speed(set),
		.uart_inbound(inbound),
		.data_received(data)
	);

	initial begin
        reset <= 1'b1;
        #3
        reset <= 1'b0;
		$readmemb("uart_rx_tb.tv", testvectors, 0, 65536);	
		vectornum = 0;

		//dump file
		$dumpfile("uart_rx_tb.vcd");
		$dumpvars(0, uart_rx_tb);
	end

	always begin
		#5; clk = 1;
		#5; clk = 0;
	end
	

	always @(posedge clk) begin
        speed <= testvectors[vectornum][23:11];
        set <= testvectors[vectornum][10];
        rx <= testvectors[vectornum][9];
        data_expected <= testvectors[vectornum][8:1];
		inbound_expected <= testvectors[vectornum][0];
	end

	always @(negedge clk) begin
		if (inbound_expected != inbound) $display("ERROR, uart_rx, inbound, %d", vectornum+1);
        if (data_expected != data) $display("ERROR, uart_rx, data, %d", vectornum+1);
		vectornum = vectornum + 1;

		if (vectornum == 65536) $finish;
	end
endmodule
