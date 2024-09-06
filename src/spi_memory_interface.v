(* keep_hierarchy *)
module spi_memory_interface (
		input wire clk,
		input wire reset,
		input wire [15:0] memory_write,
		input wire [15:0] request_address,
		input wire request_type,
		input wire request,

		input wire special_operation,

		output reg [15:0] data_out,
		output reg memory_ready,
		output reg write_complete,
		output reg memory_critical,

		input wire miso,
		output reg cs,
		output reg mosi,
		output wire sck,

		input wire uart_inbound,
		input wire [7:0] uart_data
	);
	
	// all here in reverse order for sending
	localparam [7:0] WREN = 8'b01100000;
	localparam [7:0] READ = 8'b11000000;
	localparam [7:0] WRITE = 8'b01000010;
	localparam [7:0] STORE = 8'b00111100;
	localparam [15:0] UART_ADDRESS = 16'b00111111110100000;
	
	reg cycle, uart_waiting, cpu_waiting, r_type, sck_reg, store_waiting, temp, read_temp;
	assign sck = sck_reg;
	reg [15:0] data_c, address;
	reg [7:0] data_u;

	reg [3:0] bit_counter, bit_count;
	reg [15:0] active_register;

	reg [2:0] stage;
	reg [1:0] operation, section;

	always @(posedge clk or posedge reset)
	begin
		if (reset) begin
			stage <= 3'b0;
			operation <= 2'b0;
			section <= 2'b0;
			active_register <= 16'b0;
			bit_counter <= 4'b0;
			bit_count <= 4'b0;
			data_u <= 8'b0;
			data_c <= 16'b0;
			address <= 16'b0;
			sck_reg <= 1'b0;
			cycle <= 1'b0;
			uart_waiting <= 1'b0;
			cpu_waiting <= 1'b0;
			r_type <= 1'b0;
			store_waiting <= 1'b0;
			mosi <= 1'b0;
			data_out <= 16'b0;
			memory_ready <= 1'b0;
			write_complete <= 1'b0;
			memory_critical <= 1'b0;
			cs <= 1'b1;
			temp <= 1'b0;
			read_temp <= 1'b0;
		end else begin
			memory_ready <= 1'b0;
			write_complete <= 1'b0;
			memory_critical <= 1'b0;
			temp <= 1'b0;
			if (request) begin
				cpu_waiting <= 1'b1;
				data_c <= {memory_write[0], memory_write[1],
				memory_write[2], memory_write[3], memory_write[4], memory_write[5], memory_write[6],
				memory_write[7], memory_write[8], memory_write[9], memory_write[10], memory_write[11],
				memory_write[12], memory_write[13], memory_write[14], memory_write[15]};
				address <= {request_address[0], request_address[1], request_address[2], request_address[3], request_address[4],
				request_address[5], request_address[6], request_address[7], request_address[8], request_address[9],
				request_address[10], request_address[11], request_address[12], request_address[13], request_address[14],
				request_address[15]};
				r_type <= request_type;
			end
			if (uart_inbound) begin
				data_u <= {uart_data[0], uart_data[1], uart_data[2], uart_data[3], uart_data[4], uart_data[5], uart_data[6], uart_data[7]};
				uart_waiting <= 1'b1;
			end
			if (special_operation) begin
				store_waiting <= 1'b1;
			end
			case (stage)
				3'b000: begin
					if (uart_waiting || cpu_waiting || store_waiting) begin
						cs <= 1'b0;
						section <= 2'b00;
						if (uart_waiting) begin
							operation <= 2'b00;
							stage <= 3'b100;
						end else if (r_type && cpu_waiting) begin
							operation <= 2'b01;
							stage <= 3'b100;
						end else if ((~r_type) && cpu_waiting) begin
							operation <= 2'b10;
							active_register <= {address[0], 7'b0, READ};
							mosi <= READ[0];
							bit_counter <= 4'b0;
							bit_count <= 4'b1111;
							stage <= 3'b110;
						end else if (store_waiting) begin
							operation <= 2'b11;
							stage <= 3'b100;
						end
					end
					sck_reg <= 1'b0;
				end
				3'b001: begin // read
					bit_count <= 4'b1111;
					sck_reg <= 1'b0;
					temp <= 1'b1;
					if (section == 2'b01) begin
						active_register <= {1'b0, address[15:1]};
						mosi <= address[1];
						stage <= 3'b110;
					end else if (section == 2'b10) begin
						data_out <= active_register;
						section <= 2'b11;
					end else begin
						stage <= 3'b101;
						memory_ready <= 1'b1;
						cpu_waiting <= 1'b0;
						cs <= 1'b1;
						sck_reg <= 1'b0;
					end
				end
				3'b010: begin // write / uart
					bit_count <= 4'b1111;
					sck_reg <= 1'b0;
					cs <= 1'b0;
					// cycle <= 1'b0;
					temp <= 1'b1;
					if (section == 2'b01) begin
						active_register <= {(operation == 2'b00) ? UART_ADDRESS[0] : address[0], 7'b0, WRITE};
						mosi <= WRITE[0];
					end else if (section == 2'b10) begin
						active_register <= {1'b0, (operation == 2'b00) ? UART_ADDRESS[15:1] : address[15:1]};
						mosi <= (operation == 2'b00) ? UART_ADDRESS[1] : address[1];
						memory_critical <= (operation == 2'b01) && (address == UART_ADDRESS); 
					end else if (section == 2'b11) begin
						active_register <= (operation == 2'b00) ? {data_u, 8'b0} : data_c;
						mosi <= (operation == 2'b00) ? 1'b0 : data_c[0];
					end
					stage <= 3'b110;	
				end
				3'b011: begin // store
					cs <= 1'b0;
					mosi <= STORE[0];
					active_register[7:0] <= STORE;
				end
				3'b100: begin // wren
					active_register <= {8'b0, WREN};
					mosi <= WREN[0];
					stage <= 3'b110;
					bit_count <= 4'b0111;
				end
				3'b101: begin // ending
					cs <= 1'b1;
					sck_reg <= 1'b0;
					active_register <= 16'b0;
					stage <= 3'b000;
				end
				3'b110: begin // send
					if (cycle) begin
						if (sck_reg && ~(bit_count == bit_counter)) begin
								sck_reg <= 1'b0;
								mosi <= active_register[0];
								bit_counter <= bit_counter + 4'b0001;
						end else begin
							if (bit_counter == bit_count) begin
								bit_counter <= 4'b0;
								case (operation)
									2'b00,
									2'b01: begin
										if (section == 2'b00) begin
											cs <= 1'b1;
											section <= 2'b01;
											stage <= 3'b010;
										end else if (section == 2'b01) begin
											section <= 2'b10;
											stage <= 3'b010;
										end else if (section == 2'b10) begin
											stage <= 3'b010;
											section <= 2'b11;
										end else begin
											stage <= 3'b101;
											if (operation <= 2'b00) uart_waiting <= 1'b0; else begin
												cpu_waiting <= 1'b0;
												write_complete <= 1'b1;
											end
										end
									end
									2'b10: begin
										if (section == 2'b00) begin
											stage <= 3'b001;
											section <= 2'b01;
										end else if (section == 2'b01) begin
											stage <= 3'b111;
											read_temp <= 1'b1;
											section <= 2'b10;
										end
									end
									2'b11: begin
										if (section == 2'b00) begin
											cs <= 1'b1;
											section <= 2'b01;
											stage <= 3'b011;
										end else begin
											stage <= 3'b101;
											store_waiting <= 1'b0;
										end
									end
								endcase
							end else begin
								if (~temp) begin
									active_register <= {active_register >> 1};
									sck_reg <= 1'b1;
								end
							end
						end
					end else if (bit_count == bit_counter) begin
						if (temp) begin
							sck_reg <= 1'b1;
							cycle <= ~cycle;
						end else begin
							temp <= 1'b1;
						end
					end
					if (~(bit_count == bit_counter)) cycle <= ~cycle;
				end
				3'b111: begin // receive
					if (cycle) begin
						if (read_temp) begin
							active_register[0] <= miso;
							read_temp <= 1'b0;
						end else if (sck_reg) begin
							sck_reg <= 1'b0;
							active_register <= {active_register << 1};
							bit_counter <= bit_counter + 4'b0001;
						end else begin
							if (bit_counter == bit_count) begin
								bit_counter <= 4'b0;
								stage <= 3'b001;
							end else begin
								sck_reg <= 1'b1;
							end
							active_register[0] <= miso;
						end
					end
					cycle <= ~cycle;
				end
			endcase
		end
	end
endmodule
