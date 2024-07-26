// BHE, BLE, and CS Always set to High
module ram_16bit (
    input wire clk,              
    input wire we,   // write enable
    input wire oe,   // read enable
    input wire [17:0] addr, // bus (256k locations)
    inout wire [15:0] data  // io pin 
);

    reg [15:0] memory [0:262143];
    reg [15:0] dout;

    wire data_enable = !we && oe; 

    assign data = data_enable ? dout : 16'bz;

    always @(posedge clk) begin
        if (we) begin
            memory[addr] <= data; // write data to memory
        end else if (oe) begin
            dout <= memory[addr]; // read data from memory
        end
    end
endmodule

module instr_addr_reg (
    input wire clk,
    input wire load_addr, // load from ram
    input wire inc_addr,  // increment instruction
    input wire [17:0] addr, 
    output reg [17:0] instr_addr
);

    always @(posedge clk) begin
        if (load_addr) begin
            instr_addr <= addr; // load ram
        end else if (inc_addr) begin
            instr_addr <= instr_addr + 1; // increment instruction
        end
    end
endmodule

//WARNING!!!! CONTROL UNIT IS NOT FUNCTION. JUST HAS ALL THE OP CODES/SETTINGS!!! ADD IT IN!!!!!!
module control_unit (
    input wire clk,
    input wire [15:0] instruction, // from the RAM
    output reg inc_addr            // increment instruction
);

    always @(posedge clk) begin
        // Reset control signals
        inc_addr <= 0;

        // Decode opcode and settings
        case (instruction[3:0])
            4'b0000: begin // NOP (No operation)
                inc_addr <= 1; // Increment address
            end
            4'b0001: begin // Arithmetic operations (ADD, SUB, MULT, NAND)
                case (instruction[6:4]) // Decode settings
                    3'b000: begin // ADD
                        inc_addr <= 1;
                    end
                    3'b001: begin // SUB
                        inc_addr <= 1;
                    end
                    3'b010: begin // MULT
                        inc_addr <= 1;
                    end
                    3'b011: begin // NAND
                        inc_addr <= 1;
                    end
                    default: begin
                        inc_addr <= 1;
                    end
                endcase
            end
            4'b0010: begin // Immediate operations (ADD Immediate, MULT Immediate)
                case (instruction[6:4])
                    3'b000: begin // ADD Immediate
                        inc_addr <= 1;
                    end
                    3'b001: begin // MULT Immediate
                        inc_addr <= 1;
                    end
                    default: begin
                        inc_addr <= 1;
                    end
                endcase
            end
            4'b0011: begin // Shift operations (Shift Left, Shift Right)
                case (instruction[6:4])
                    3'b000: begin // Shift Left
                        inc_addr <= 1;
                    end
                    3'b001: begin // Shift Right
                        inc_addr <= 1;
                    end
                    default: begin
                        inc_addr <= 1;
                    end
                endcase
            end
            4'b0100: begin // Jump operations
                case (instruction[6:4])
                    3'b000: begin // Jump
                        inc_addr <= 1;
                    end
                    3'b001: begin // Jump if Zero
                        inc_addr <= 1;
                    end
                    3'b010: begin // Jump if Greater
                        inc_addr <= 1;
                    end
                    default: begin
                        inc_addr <= 1;
                    end
                endcase
            end
            4'b0101: begin // Other jump operations
                inc_addr <= 1;
            end
            4'b0110: begin // Store operations
                case (instruction[6:4])
                    3'b000: begin // Store
                        inc_addr <= 1;
                    end
                    3'b001: begin // Store Register
                        inc_addr <= 1;
                    end
                    default: begin
                        inc_addr <= 1;
                    end
                endcase
            end
            4'b0111: begin // Load Immediate
                inc_addr <= 1;
            end
            4'b1000: begin // UART call
                inc_addr <= 1;
            end
            default: begin // Default case: increment the instruction address
                inc_addr <= 1; // Increment address by default
            end
        endcase
    end
endmodule



// module ram_16bit (
//     // BHE, BLE, and CS Always set to High
//     input wire clk,              
//     input wire we,   // write enable
//     input wire oe,   // read enable
//     input wire [17:0] addr, // bus (256k locations)
//     inout wire [15:0] data  // io pin 
// );

//     // Memory array with 262144 locations, each 16 bits wide
//     reg [15:0] memory [0:262143];
//     reg [15:0] dout; // Data output register

//     // Enable data output if write enable is low and read enable is high
//     wire data_enable = !we && oe; 

//     // Conditional assignment to data bus
//     assign data = data_enable ? dout : 16'bz;

//     always @(posedge clk) begin
//         if (we) begin
//             // Write data to memory if write enable is high
//             memory[addr] <= data;
//         end else if (oe) begin
//             // Read data from memory if read enable is high
//             dout <= memory[addr];
//         end
//     end
// endmodule

// module instr_addr_reg (
//     input wire clk,
//     input wire load_addr, // load from ram
//     input wire inc_addr,  // increment instruction
//     input wire [17:0] addr, 
//     output reg [17:0] instr_addr
// );

//     always @(posedge clk) begin
//         if (load_addr) begin
//             instr_addr <= addr; // load ram
//         end else if (inc_addr) begin
//             instr_addr <= instr_addr + 1; // increment instruction
//         end
//     end
// endmodule

// module control_unit (
//     input wire clk,
//     input wire [15:0] instruction, // from the RAM
//     output reg we,                 // write enable
//     output reg oe,                 // output enable
//     output reg load_addr,          // load from RAM
//     output reg inc_addr,           // increment instruction
//     output reg [17:0] addr         // address for memory operations
// );

//     always @(posedge clk) begin
//         case (instruction[3:0]) // Decode opcode from the lower 4 bits
//             4'b0000: begin // NOP (No operation)
//                 we <= 0;
//                 oe <= 0;
//                 load_addr <= 0;
//                 inc_addr <= 1; // Increment address
//             end
//             4'b0001: begin // Opcode 0001 (Arithmetic operations)
//                 case (instruction[6:4]) // Decode settings from bits 6 to 4
//                     3'b000: begin // ADD
//                         // Perform ADD operation
//                         we <= 1;
//                         oe <= 0;
//                         load_addr <= 0;
//                         inc_addr <= 0;
//                     end
//                     3'b001: begin // SUB
//                         // Perform SUB operation
//                         we <= 1;
//                         oe <= 0;
//                         load_addr <= 0;
//                         inc_addr <= 0;
//                     end
//                     3'b010: begin // MULT
//                         // Perform MULT operation
//                         we <= 1;
//                         oe <= 0;
//                         load_addr <= 0;
//                         inc_addr <= 0;
//                     end
//                     3'b011: begin // NAND
//                         // Perform NAND operation
//                         we <= 1;
//                         oe <= 0;
//                         load_addr <= 0;
//                         inc_addr <= 0;
//                     end
//                 endcase
//             end
//             4'b0010: begin // Opcode 0010 (Immediate operations)
//                 case (instruction[6:4])
//                     3'b000: begin // ADD Immediate
//                         we <= 1;
//                         oe <= 0;
//                         load_addr <= 0;
//                         inc_addr <= 0;
//                     end
//                     3'b001: begin // MULT Immediate
//                         we <= 1;
//                         oe <= 0;
//                         load_addr <= 0;
//                         inc_addr <= 0;
//                     end
//                 endcase
//             end
//             4'b0011: begin // Opcode 0011 (Shift operations)
//                 case (instruction[6:4])
//                     3'b000: begin // Shift Left
//                         we <= 1;
//                         oe <= 0;
//                         load_addr <= 0;
//                         inc_addr <= 0;
//                     end
//                     3'b001: begin // Shift Right
//                         we <= 1;
//                         oe <= 0;
//                         load_addr <= 0;
//                         inc_addr <= 0;
//                     end
//                 endcase
//             end
//             4'b0100: begin // Jump operations
//                 case (instruction[6:4])
//                     3'b000: begin // Jump
//                         we <= 1;
//                         oe <= 0;
//                         load_addr <= 0;
//                         inc_addr <= 0;
//                     end
//                     3'b001: begin // Jump if Zero
//                         we <= 1;
//                         oe <= 0;
//                         load_addr <= 0;
//                         inc_addr <= 0;
//                     end
//                     3'b010: begin // Jump if Greater
//                         we <= 1;
//                         oe <= 0;
//                         load_addr <= 0;
//                         inc_addr <= 0;
//                     end
//                 endcase
//             end
//             // Add more opcodes here
//             4'b0110: begin // Store operations
//                 case (instruction[6:4])
//                     3'b000: begin // Store
//                         we <= 1;
//                         oe <= 0;
//                         load_addr <= 0;
//                         inc_addr <= 0;
//                     end
//                     3'b001: begin // Store Register
//                         we <= 1;
//                         oe <= 0;
//                         load_addr <= 0;
//                         inc_addr <= 0;
//                     end
//                 endcase
//             end
//             4'b0111: begin // Load Immediate
//                 we <= 1;
//                 oe <= 0;
//                 load_addr <= 0;
//                 inc_addr <= 0;
//             end
//             4'b1000: begin // UART call
//                 we <= 0;
//                 oe <= 0;
//                 load_addr <= 0;
//                 inc_addr <= 0;
//                 // UART specific actions
//             end
//             default: begin // Default case: increment the instruction address
//                 we <= 0;
//                 oe <= 0;
//                 load_addr <= 0;
//                 inc_addr <= 1; // Increment address by default
//             end
//         endcase
//     end
// endmodule
