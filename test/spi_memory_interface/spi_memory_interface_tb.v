`include "spi_memory_interface.v"

module spi_memory_interface_tb;
	
	//i/0 for uart
	reg clk, reset;
	
	//for testbench
	reg [31:0] vectornum;
	reg [66:0] testvectors [100000:0];

	reg [15:0]	memory_write, request_address, data_out_e;
	reg [7:0] uart_data;
	reg request_type, request, special_operation, miso, uart_inbound;
	wire [15:0] data_out;
	wire mosi, sck, cs, memory_ready, write_complete, memory_critical;
	reg mosi_e, sck_e, cs_e, memory_ready_e, write_complete_e, memory_critical_e;


	spi_memory_interface SPI (
		.clk(clk),
		.reset(reset),
        .memory_write(memory_write),
		.request_address(request_address),
		.request_type(request_type),
		.request(request),

		.special_operation(special_operation),

		.data_out(data_out),
		.memory_ready(memory_ready),
		.write_complete(write_complete),
		.memory_critical(memory_critical),

		.miso(miso),
		.cs(cs),
		.mosi(mosi),
		.sck(sck),

		.uart_inbound(uart_inbound),
		.uart_data(uart_data)
	);

	initial begin
        reset <= 1'b1;
        #3
        reset <= 1'b0;
		$readmemb("spi_memory_interface_tb.tv", testvectors, 0, 65536);	
		vectornum = 0;

		//dump file
		$dumpfile("spi_memory_interface_tb.vcd");
		$dumpvars(0, spi_memory_interface_tb);
	end

	always begin
		#5; clk = 1;
		#5; clk = 0;
	end
	

	always @(posedge clk) begin
		memory_write <= testvectors[vectornum][66:51];
		request_address <= testvectors[vectornum][50:35];
		uart_data <= testvectors[vectornum][34:27];
		request_type <= testvectors[vectornum][26];
		request <= testvectors[vectornum][25];
		special_operation <= testvectors[vectornum][24];
		miso <= testvectors[vectornum][23];
		uart_inbound <= testvectors[vectornum][22];
		data_out_e <= testvectors[vectornum][21:6];
		mosi_e <= testvectors[vectornum][5];
		sck_e <= testvectors[vectornum][4];
		cs_e <= testvectors[vectornum][3];
		memory_ready_e <= testvectors[vectornum][2];
		write_complete_e <= testvectors[vectornum][1];
		memory_critical_e <= testvectors[vectornum][0]; 
	end

	always @(negedge clk) begin
		if (mosi_e != mosi) $display("ERROR, spi_memory_interface, mosi, %d", vectornum+1);
		if (write_complete_e != write_complete) $display("ERROR, spi_memory_interface, write complete, %d", vectornum+1);
		if (memory_critical_e != memory_critical) $display("ERROR, spi_memory_interface, memory critical, %d", vectornum+1);
		if (memory_ready_e != memory_ready) $display("ERROR, spi_memory_interface, memory ready, %d", vectornum+1);
		if (cs_e != cs) $display("ERROR, spi_memory_interface, cs, %d", vectornum+1);
		if (sck_e != sck) $display("ERROR, spi_memory_interface, sck, %d", vectornum+1);
		vectornum = vectornum + 1;

		if (vectornum == 65536) $finish;
	end
endmodule
