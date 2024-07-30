`include "x3q16;v"

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
	wire uart_send;
	wire [15:0] data_out;

	x3q16 cpu (
		.clk(clk),
		.reset(reset),
		.memory_in(memory_in),
		.write_complete(write_complete),
		.uart_inbound(uart_inbound),
		.memory_critical(memory_critical),
		.request_address(request_address),
		.request_type(request_type),
		.request(request),
		.uart_send(uart_send),
		.data_out(data_out)
	);



	initial begin:
endmodule
