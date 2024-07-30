// `include "x3q16alu.v"
// `include "keccakf1600_statepermutate.v"
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
	wire [4:0] kreg1; 
	wire [1:0] kreg1_extended; 
	wire ksettings;
	
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
	assign kreg1 = current_instruction[11:7];
	assign kreg1_extended = current_instruction[13:12];
	assign ksettings = current_instruction[14];

	localparam [64*24-1:0] round_constants = {
    64'h0000000000000001,
    64'h0000000000008082,
    64'h800000000000808a,
    64'h8000000080008000,
    64'h000000000000808b,
    64'h0000000080000001,
    64'h8000000080008081,
    64'h8000000000008009,
    64'h000000000000008a,
    64'h0000000000000088,
    64'h0000000080008009,
    64'h000000008000000a,
    64'h000000008000808b,
    64'h800000000000008b,
    64'h8000000000008089,
    64'h8000000000008003,
    64'h8000000000008002,
    64'h8000000000000080,
    64'h000000000000800a,
    64'h800000008000000a,
    64'h8000000080008081,
    64'h8000000000008080,
    64'h0000000080000001,
    64'h8000000080008008
	};

	reg [64*24-1:0] keccak_state;
	reg [64*24-1:0] next_keccak_state;
	reg [63:0] const_1;
	reg [63:0] const_2;

	keccak_round k_round (
		.instate(keccak_state), 
		.round_constant1(const_1), 
		.round_constant2(const_2), 
		.outstate(next_keccak_state)
	);

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
			keccak_state <= 1536'b0;
			const_1 <= 64'b0;
			const_2 <= 64'b0;
		end else begin
			if (uart_inbound) begin
				registers[1][0] <= 1'b1;
			end
			
			if (memory_critical) begin
				registers[1][1] <= 1'b1;
			end
			registers[0] <= 16'b0;
			request <= 1'b0;

			// execution
			case (execution_stage)
				3'b000: begin // load/setup operation stage 1
					if (memory_ready) begin
						current_instruction <= memory_in;
						current_address <= request_address;
						alu_a <= request_address;
						alu_b <= 16'h1;
						execution_stage <= 3'b101;
					end
				end
				3'b001: begin //operation stage 1
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
						4'b0011: begin //Keccak Round
                            // load constants
							const_1 <= round_constants[kreg1*64+:64];
							const_2 <= round_constants[kreg1*64+7'd64+:64];
							execution_stage <= 3'b010;
						end
						4'b0100: begin //Jump
							if (reg_out != 3'b000) registers[reg_out] <= current_address;
							if (settings == 3'b110) request <= 1'b1; else case (settings) 
								3'b000: jump_con <= 1'b1;
								3'b001: jump_con <= registers[1][4];
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
							alu_a <= current_address;
							if (settings[0] == 1) begin
								request_address <= registers[reg1];
								alu_b <= 16'h1;
							end else alu_b <= 16'h2;
							request <= 1'b1;
							execution_stage <= 3'b010;
						end
						4'b0110: begin //Store
							data_out <= registers[reg2];
							if (settings[0] == 1) begin
								request_address <= registers[reg1];
								request_type <= 1'b1;
								alu_a <= 16'h1;
							end else alu_b <= 16'h2;
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
						4'b1001: begin //Keccak load/unload
							alu_a <= current_address;
							alu_b <= 1'h1;
                            if (ksettings == 0) begin //load
                                request_address <= registers[settings];
                                request <= 16'b1;
                            end else begin // unload
							    data_out <= keccak_state[kreg1*64+kreg1_extended*16+:16];
                                request_address <= registers[settings];
                                request_type <= 1'b1;
							    request <= 1'b1;
                            end
							execution_stage <= 3'b010;
						end
					endcase
				end
				3'b010: begin // operation stage 2
					case (opcode)
						4'b0001: begin //ALU
							if (reg_out != 3'b000) begin
								registers[reg_out] <= alu_result;
							end
							registers[1][3] <= eF;
							registers[1][2] <= gaF;
							registers[1][4] <= alu_result == 16'h0000;
							execution_stage <= 3'b100;
						end
						4'b0010: begin //ALUI
							if (reg_out != 3'b000) begin
								registers[reg_out] <= alu_result;
							end
							registers[1][3] <= eF;
							registers[1][2] <= gaF;
							registers[1][4] <= alu_result == 16'h0000;
							execution_stage <= 3'b100;
						end
						4'b0011: begin //Keccak Round
							keccak_state <= next_keccak_state; // assign keccak state after calc
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
							if (memory_ready == 1) begin
								if (settings[0] == 1) begin
									registers[reg_out] <= memory_in;
									request_address <= alu_result;
									execution_stage <= 3'b100;
								end else begin
									request_address <= memory_in;
									request <= 1'b1;
									execution_stage <= 3'b011;
								end
							end
						end
						4'b0110: begin //Store
							if (settings[0] == 1) begin
								if (write_complete) begin
									request_address <= alu_result;
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
						4'b1001: begin //Keccak load/unload
                            if (ksettings == 0) begin //load
                                if (memory_ready) begin
								    keccak_state[kreg1*64+kreg1_extended*16+:16] <= memory_in;
                                    request_address <= alu_result;
								    execution_stage <= 3'b100;
                                end
                            end else begin // unload/store
								if (write_complete) begin
									request_address <= alu_result;
                                    execution_stage <= 3'b100;
								end
                            end
						end
					endcase
				end
				3'b011: begin // operation stage 3
					if (opcode == 4'b0101) begin // load or store
						if (memory_ready) begin
							registers[reg_out] <= memory_in;
							request_address <= alu_result;
							execution_stage <= 3'b100;
						end
                    end else begin
						if (write_complete) begin 
							request_address <= alu_result;
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
					alu_mode <= 3'b000;
				end
				3'b101: begin // Setup stage 2
					request_address <= alu_result;
					execution_stage <= 3'b001;
				end
			endcase
		end
	end
endmodule
