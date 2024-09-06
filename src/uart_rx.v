(* keep_hierarchy *)
module uart_rx (
		input wire clk,
		input wire reset,
		input wire rx,
		input wire [12:0] speed,
		input wire set_speed,
		output reg uart_inbound,
		output reg [7:0] data_received
	);

	localparam UART_SPEED_DEFAULT = 13'h1869;

	reg [12:0] cycles_per_bit, cycle_counter;

	reg [7:0] data;
	reg [1:0] stage;
	reg [2:0] bit_counter;
	
	always @(posedge clk or posedge reset)
	begin
		if (reset) begin
			cycles_per_bit <= UART_SPEED_DEFAULT;
			cycle_counter <= 13'h0;
			data <= 8'h00;
			uart_inbound <= 1'b0;
			data_received <= 8'b0;
			stage <= 2'b0;
			bit_counter <= 3'b0;
		end else if (set_speed) begin
			cycles_per_bit <= speed;
		end else begin
			case (stage)
				2'b00: begin
					if (~rx) begin
						data <= 8'b0;
						bit_counter <= 3'b0;
						stage <= 2'b01;
						cycle_counter <= (cycles_per_bit != 13'b0) ? ((13'b1111111111110 - cycles_per_bit) + 13'h0002) : 13'b0;
					end
					uart_inbound <= 1'b0;
					data_received <= 8'b0;
				end
				2'b01: begin
					if (cycle_counter == cycles_per_bit) begin
						cycle_counter <= 13'b0;
						data[bit_counter] <= rx;
						if (bit_counter == 3'b111) begin
							stage <= 2'b10; 
						end else bit_counter <= bit_counter + 3'b001;
					end else cycle_counter <= cycle_counter + 13'b0000000000001;
				end
				2'b10: begin
					if (cycle_counter == cycles_per_bit) begin
						uart_inbound <= 1'b1;
						data_received <= data;
						stage <= 2'b00;
					end else cycle_counter <= cycle_counter + 13'b0000000000001;
				end
			endcase
		end
	end
endmodule
