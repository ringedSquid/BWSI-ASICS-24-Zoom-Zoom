`include "x3q16alu.v"
module x3q16 (
		input clk,
		input reset,

		input [15:0] memory_in,
		input memory_ready,
		input write_complete,

		input uart_inbound,
		input memory_critical,

		output reg [15:0] request_address,
		output reg request_type, //0 is read, 1 is writes data_out to address
		output reg request,
		output reg uart_send, //just do what you need to store it while it is being sent; uses data_out
		output reg [15:0] data_out
	);
	reg [15:0] current_address; //!!!CURRENT INSTRUCTION ADDRESS!!!
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
	reg [2:0] execution_stage;
	reg jump_con;
	always @(posedge clk or posedge reset)
	begin
		if (reset) begin
			//reset
			for (i = 0; i < 8; i = i + 1) begin
				registers[i] <= 16'b0;
			end
			current_address <= 16'h0000;
			current_instruction <= 16'h0000;
			request_address <= 16'b0;
			request_type <= 1'b0;
			request <= 1'b1;
			data_out <= 16'b0;
			uart_send <= 1'b0;
			execution_stage <= 3'b000;
			alu_a <= 16'b0;
			alu_b <= 16'b0;
			alu_mode <= 3'b0;
			jump_con <= 1'b0;
		end else begin
			if (uart_inbound) begin
				registers[1][0] <= 1'b1;
			end
			
			if (memory_critical) begin
				registers[1][1] <= 1'b1;
			end
			registers[0] <= 16'b0;
			registers[1][3] <= eF;
			registers[1][2] <= gaF;
			registers[0] <= 16'b0;
			request <= 1'b0;

			// execution
			case (execution_stage)
				3'b000: begin // load/setup operation
					if (memory_ready) begin
						current_instruction <= memory_in;
						current_address <= request_address;
						request_address <= request_address + 1'b1;
						execution_stage <= 3'b001;
					end
				end
				3'b001: begin //operation
					case (opcode)
						4'b0000: execution_stage <= 3'b100; //No Operation
						4'b0001: begin //ALU
							alu_mode <= settings;
							alu_a <= registers[reg1];
							alu_b <= registers[reg2];
							execution_stage <= 3'b010;
						end
						4'b0010: begin //ALUI
							alu_mode <= settings[0] ? 3'b010 : 3'b000;
							alu_a <= registers[2];
							alu_b <= {8'h00, imm_lower};
							execution_stage <= 3'b010;
						end
						4'b0100: begin //Jump
							if (reg_out != 3'b000) registers[reg_out] <= current_address;
							if (settings == 3'b110) request <= 1'b1; else case (settings) 
								3'b000: jump_con <= 1'b1;
								3'b001: jump_con <= alu_result == 16'h0000;
								3'b010: jump_con <= registers[1][2];
								3'b011: jump_con <= ~registers[1][2];
								3'b100: jump_con <= registers[1][1];
								3'b101: jump_con <= registers[1][0];
								3'b111: jump_con <= registers[1][3];
								default: jump_con <= 1'b0;
							endcase
							execution_stage <= 3'b010;
						end
						4'b0101: begin //Load
							if (settings[0]) request_address <= registers[reg1];
							request <= 1'b1;
							execution_stage <= 3'b010;
						end
						4'b0110: begin //Store
							data_out <= registers[reg2];
							if (settings[0]) begin
								request_address <= registers[reg1];
								request_type <= 1'b1;
							end
							request <= 1'b1;
							execution_stage <= 3'b010;
						end
						4'b0111: begin //Load Immediate
							registers[reg_out] <= {imm_upper, 7'b0};
							execution_stage <= 3'b100;
						end
						4'b1000: begin //Uart Call
							data_out <= registers[reg1];
							uart_send <= 1'b1;
							execution_stage <= 3'b100;
						end
						default: begin end
					endcase
				end
				3'b010: begin
					case (opcode)
						4'b0001: begin //ALU
							if (reg_out != 3'b000) begin
								registers[reg_out] <= alu_result;
							end
							execution_stage <= 3'b100;
						end
						4'b0010: begin //ALUI
							if (reg_out != 3'b000) begin
								registers[reg_out] <= alu_result;
							end
							execution_stage <= 3'b100;
						end
						4'b0100: begin //Jump
							if (settings == 3'b110) begin
								if (memory_ready) begin
									request_address <= memory_in;
									execution_stage <= 3'b100;
								end
							end else begin
								if (jump_con) begin
									request_address <= registers[reg1];
								end
								execution_stage <= 3'b100;
							end 
						end
						4'b0101: begin //Load
							if (memory_ready) begin
								if (settings[0]) begin
									registers[reg_out] <= memory_in;
									request_address <= current_address + 1'b1;
									execution_stage <= 3'b100;
								end else begin
									request_address <= memory_in;
									request <= 1'b1;
									execution_stage <= 3'b011;
								end
							end
						end
						4'b0110: begin //Store
							if (settings[0]) begin
								if (write_complete) begin
									request_address <= current_address + 1'b1;
									execution_stage <= 3'b100;
								end
							end else begin
								if (memory_ready) begin
									request_address <= memory_in;
									request_type <= 1'b1;
									request <= 1'b1;
									execution_stage <= 3'b011;
								end
							end
						end
						default: begin end
					endcase
				end
				3'b011: begin
					if (opcode == 4'b0101) begin // load or store
						if (memory_ready) begin
							registers[reg_out] <= memory_in;
							request_address <= current_address + 16'h0002;
							execution_stage <= 3'b100;
						end
					end else begin
						if (write_complete) begin 
							request_address <= current_address + 16'h0002;
							execution_stage <= 3'b100;
						end
					end
				end
				3'b100: begin // post operation / send next load request
					execution_stage <= 3'b000;
					request_type <= 1'b0;
					request <= 1'b1;
					data_out <= 16'b0;
					uart_send <= 1'b0;
				end
				default: begin
					execution_stage <= 3'b000;
					request <= 1'b0;
				end
			endcase
		end
	end
endmodule
