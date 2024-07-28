module x3q16 (
		input clk,
		input reset,
		input [15:0] memory_in,
		input memory_ready,
		input [15:0] current_address,

		output reg [15:0] request_address,
		output reg [1:0] request_type, //00 is next instruction, 01 is read, 10 is write and give next instruction, 11 is jump to
		output reg request,
		output reg [15:0] store_data,

		output reg [15:0] uart_out,
		output reg uart_send, //just do what you need to store it while it is being sent

		input uart_inbound,
		input memory_critical
	);
	reg [15:0] last_address;
	reg [15:0] current_instruction;
	
	reg [15:0] registers [7:0];
	
	wire [3:0] opcode;
	wire [2:0] settings;
	wire [2:0] reg1, reg2, reg_out;
	wire [8:0] imm_upper;
	wire [7:0] imm_lower;
	
	reg [2:0] alu_mode;
	reg [15:0] alu_a, alu_b;
	wire [15:0] alu_result;
	wire eF, gaF;
	
	assign opcode = current_instruction[3:0];
	assign settings = current_instruction[6:4];
	assign reg1 = current_instruction[9:7];
	assign reg2 = current_instruction[12:10];
	assign reg_out = current_instruction[15:13];
	assign imm_lower = current_instruction[15:8];
	assign imm_upper = current_instruction[15:7];

	x3q16alu ALU (
		.a(alu_a),
		.b(alu_b),
		.mode(alu_mode),
		.result(alu_result),
		.equal_flag(eF),
		.greater_a_flag(gaF)
	);

	integer i;
	reg [1:0] mode; // 00 is instruction, 01 is data in next address, 10 is data from address, 11 is reg repo.
	reg jump_con, mem_halt;
	always @(posedge clk or posedge reset)
	begin
		if (reset) begin
			//reset
			for (i = 0; i < 8; i = i + 1) begin
				registers[i] <= 16'b0;
			end
			last_address <= 16'hffff;
			current_instruction <= 16'hfff;
			request_address <= 16'b0;
			request_type <= 2'b0;
			request <= 1'b0;
			store_data <= 16'b0;
			uart_out <= 16'b0;
			uart_send <= 1'b0;
			mode <= 2'b0;
			jump_con <= 1'b0;
			mem_halt <= 1'b0;
		end else begin

			//Pre cycle operations
			request <= 1'b0;
			uart_send <= 1'b0;
			if (uart_inbound) begin
				registers[1][0] <= 1'b1;
			end
			
			if (memory_critical) begin
				registers[1][1] <= 1'b1;
			end
			registers[1][3] <= eF;
			registers[1][2] <= gaF;
			registers[0] <= 16'b0;
			request_type <= 2'b00;
			request_address <= 16'b0;
			store_data <= 16'b0;
			uart_out <= 16'b0;

			//Operations
			if (((memory_ready) & ~(last_address == current_address)) | mem_halt) begin
				mem_halt <= 1'b0;
				last_address <= current_address;
				if (mode == 2'b00) begin
					current_instruction <= memory_in;
				end
				case (opcode)
					4'b0000: begin end//No Operation
					4'b0001: begin //ALU
						case (mode)
							2'b00: begin
								alu_mode <= settings;
								alu_a <= registers[reg1];
								alu_b <= registers[reg2];
								mem_halt <= 1'b1;
								mode <= 2'b11;
							end
							2'b11: begin
								if (reg_out != 3'b000) begin
									registers[reg_out] <= alu_result;
								end
							end
						endcase
					end
					4'b0010: begin //ALUI
					case (mode)
							2'b00: begin
								alu_mode <= settings[0] ? 3'b010 : 3'b000;
								alu_a <= registers[2];
								alu_b <= {8'h00, imm_lower};
								mem_halt <= 1'b1;
								mode <= 2'b11;
							end
							2'b11: begin
								if (reg_out != 3'b000) begin
									registers[current_instruction[7:5]] <= alu_result;
								end
							end
						endcase
					end
					4'b0100: begin //Jump
						if (settings == 3'b110) begin
							case (mode)
								2'b00: mode <= 2'b01;
								2'b01: begin
									request_address <= memory_in;
									request_type <= 2'b11;
									mode <= 2'b00;
								end
							endcase
						end else begin
							jump_con <= 1'b0;
							case (settings) 
								3'b000: jump_con <= 1'b1;
								3'b001: jump_con <= alu_result == 16'h0000;
								3'b010: jump_con <= registers[1][2];
								3'b011: jump_con <= ~registers[1][2];
								3'b100: jump_con <= registers[1][1];
								3'b101: jump_con <= registers[1][0];
								3'b111: jump_con <= registers[1][3];
							endcase
							if (jump_con) begin
								request_address <= registers[reg1];
								request_type <= 2'b11;
							end
						end
					end
					4'b0101: begin //Load
						if (settings[0]) begin
							case (mode)
								2'b00: begin
									request_address <= registers[reg1];
									request_type <= 2'b01;
									mode <= 2'b10;
								end
								2'b10: begin
									registers[reg_out] <= memory_in;
									mode <= 2'b00;
								end
							endcase
						end else begin
							case (mode)
								2'b00: mode <= 2'b01;
								2'b01: begin
									request_address <= memory_in;
									request_type <= 2'b01;
									mode <= 2'b10;
								end
								2'b10: begin
									registers[reg_out] <= memory_in;
									mode <= 2'b00;
								end
							endcase
						end
					end
					4'b0110: begin //Store
						if (settings[0]) begin
							request_address <= registers[reg1];
							request_type <= 2'b10;
							store_data <= registers[reg2];
						end else begin
							case (mode)
								2'b00: mode <= 2'b01;
								2'b01: begin
									request_address <= memory_in;
									request_type <= 2'b10;
									store_data <= registers[reg2];
									mode <= 2'b00;
								end
							endcase
						end
					end
					4'b0111: begin //Load Immediate
						registers[settings] <= {imm_upper, 7'b0};
					end
					4'b1000: begin //Uart Call
						uart_out <= registers[reg1];
						uart_send <= 1'b1;
					end
				endcase
				if (~mem_halt) begin
					request <= 1'b1;
				end
			end
		end
	end
endmodule
