module memory_controller_arduino (
    input clk,
    input reset,

    // Interface with x3q16
    input [15:0] request_address,
    input request_type, // 0 for read, 1 for write
    input request,
    input [15:0] memory_write, 
    output reg [15:0] data_out, 
    output reg memory_ready,
    output reg write_complete,

    // Arduino output
    output reg write_enable,
    output reg register_enable,
    output reg read_enable,
    output reg lower_bit,
    output reg upper_bit,

    // Arduino input
    input lower_byte_in,
    input upper_byte_in,

    input [7:0] data_input_pins, 
    output reg [7:0] data_output_pins,

    // Updated iovalue signal
    output reg [7:0] iovalue,  // 8-bit: controls direction for each uio pin (0: input, 1: output)

    // UART Receiver Instantiation
    input wire uart_inbound,
    input wire [7:0] data_received  // Changed from single bit to 8 bits for data input
);

    parameter IDLE = 5'b00000;
    parameter WRITE_SETUP = 5'b00001;
    parameter WRITE_WAIT_1 = 5'b00010;
    parameter WRITE_ADDRESS_UPPER = 5'b00011;
    parameter WRITE_WAIT_2 = 5'b00100;
    parameter LOAD_DATA_LOWER = 5'b00101;
    parameter WRITE_WAIT_3 = 5'b00110;
    parameter LOAD_DATA_UPPER = 5'b00111;
    parameter WRITE_WAIT_4 = 5'b01000;
    parameter WRITE_COMPLETE = 5'b01001;
    parameter READ_SETUP = 5'b01010;
    parameter READ_WAIT_1 = 5'b01011;
    parameter READ_ADDRESS_UPPER = 5'b01100;
    parameter READ_WAIT_2 = 5'b01101;
    parameter READ_WAIT_FOR_LOWER_BYTE = 5'b01110;
    parameter READ_LOWER_BYTE = 5'b01111;
    parameter READ_WAIT_FOR_UPPER_BYTE = 5'b10000;
    parameter READ_UPPER_BYTE = 5'b10001;
    parameter READ_COMPLETE = 5'b10010;
    parameter UART_RECEIVE_ADDRESS = 5'b10011;
    parameter UART_WAIT_LOWER_BYTE = 5'b10101;
    parameter UART_RECEIVE_ADDRESS_UPPER = 5'b10110;
    parameter UART_WAIT_UPPER_BYTE = 5'b10111;
    parameter UART_RECEIVE_DATA = 5'b11000;
    parameter UART_WAIT_DATA_WRITE = 5'b11001;

    reg [4:0] state, next_state;

    reg [7:0] data_bus; 
    reg [5:0] wait_counter; 
    parameter WAIT_CYCLES = 6'd4; 

    reg uart_waiting;  
    reg [15:0] uart_memory_address;  

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            memory_ready <= 1'b0;
            write_complete <= 1'b0;
            write_enable <= 1'b0;
            read_enable <= 1'b0;
            register_enable <= 1'b0;
            lower_bit <= 1'b0;
            upper_bit <= 1'b0;
            data_bus <= 8'b0;
            data_out <= 16'b0;
            wait_counter <= 6'b0;
            data_output_pins <= 8'b0; 
            iovalue <= 8'b0; // Default all to input
            uart_waiting <= 1'b0;
            uart_memory_address <= 16'b0;  // Initialize the UART memory address
        end else begin
            state <= next_state;

            // Manage wait counter
            if (state == WRITE_WAIT_1 || state == WRITE_WAIT_2 || state == WRITE_WAIT_3 || state == WRITE_WAIT_4 ||
                state == READ_WAIT_1 || state == READ_WAIT_2 || state == UART_WAIT_LOWER_BYTE || state == UART_WAIT_UPPER_BYTE || state == UART_WAIT_DATA_WRITE) begin
                wait_counter <= wait_counter + 1;
            end else begin
                wait_counter <= 6'b0;
            end

            case (state)
                IDLE: begin
                    memory_ready <= 1'b0;
                    write_complete <= 1'b0;
                    write_enable <= 1'b0;
                    read_enable <= 1'b0;
                    register_enable <= 1'b0;
                    lower_bit <= 1'b0;
                    upper_bit <= 1'b0;
                    data_bus <= 8'b0;
                    data_out <= 16'b0;
                    data_output_pins <= 8'b0;
                    iovalue <= 8'b0;  // Set all uio pins to input mode

                    if (uart_inbound) begin
                        uart_waiting <= 1'b1;
                        uart_memory_address <= 16'b111111110100000;
                        next_state <= UART_RECEIVE_ADDRESS;
                    end else if (request) begin  // Activate when request is 1
                        if (request_type == 1'b1) begin
                            next_state <= WRITE_SETUP;
                        end else if (request_type == 1'b0) begin
                            next_state <= READ_SETUP;
                        end
                    end else begin
                        next_state <= IDLE;
                    end
                end

                // Write Operation
                WRITE_SETUP: begin
                    write_enable <= 1'b1;
                    register_enable <= 1'b1;
                    lower_bit <= 1'b1;
                    data_output_pins <= request_address[7:0]; 
                    iovalue <= 8'b11111111;  // Set all uio pins to output mode
                    next_state <= WRITE_WAIT_1;
                end

                WRITE_WAIT_1: begin
                    if (wait_counter >= WAIT_CYCLES) begin
                        next_state <= WRITE_ADDRESS_UPPER;
                    end else begin
                        next_state <= WRITE_WAIT_1;
                    end
                end

                WRITE_ADDRESS_UPPER: begin
                    lower_bit <= 1'b0;
                    upper_bit <= 1'b1;
                    data_output_pins <= request_address[15:8]; 
                    next_state <= WRITE_WAIT_2;
                end

                WRITE_WAIT_2: begin
                    if (wait_counter >= WAIT_CYCLES) begin
                        next_state <= LOAD_DATA_LOWER;
                    end else begin
                        next_state <= WRITE_WAIT_2;
                    end
                end

                LOAD_DATA_LOWER: begin
                    register_enable <= 1'b0;
                    lower_bit <= 1'b1;
                    upper_bit <= 1'b0;
                    data_output_pins <= memory_write[7:0]; 
                    next_state <= WRITE_WAIT_3;
                end

                WRITE_WAIT_3: begin
                    if (wait_counter >= WAIT_CYCLES) begin
                        next_state <= LOAD_DATA_UPPER;
                    end else begin
                        next_state <= WRITE_WAIT_3;
                    end
                end

                LOAD_DATA_UPPER: begin
                    lower_bit <= 1'b0;
                    upper_bit <= 1'b1;
                    data_output_pins <= memory_write[15:8]; 
                    next_state <= WRITE_WAIT_4;
                end

                WRITE_WAIT_4: begin
                    if (wait_counter >= WAIT_CYCLES) begin
                        next_state <= WRITE_COMPLETE;
                    end else begin
                        next_state <= WRITE_WAIT_4;
                    end
                end

                WRITE_COMPLETE: begin
                    write_enable <= 1'b0;
                    upper_bit <= 1'b0;
                    write_complete <= 1'b1;
                    iovalue <= 8'b0;  
                    next_state <= IDLE;
                end

                // Read Operation
                READ_SETUP: begin
                    iovalue <= 8'b11111111;
                    read_enable <= 1'b1;
                    register_enable <= 1'b1;
                    lower_bit <= 1'b1;
                    data_output_pins <= request_address[7:0]; 
                    next_state <= READ_WAIT_1;
                end

                READ_WAIT_1: begin
                    if (wait_counter >= WAIT_CYCLES) begin
                        next_state <= READ_ADDRESS_UPPER;
                    end else begin
                        next_state <= READ_WAIT_1;
                    end
                end

                READ_ADDRESS_UPPER: begin
                    lower_bit <= 1'b0;
                    upper_bit <= 1'b1;
                    data_output_pins <= request_address[15:8]; 
                    next_state <= READ_WAIT_2;
                end

                READ_WAIT_2: begin
                    if (wait_counter >= WAIT_CYCLES) begin
                        next_state <= READ_WAIT_FOR_LOWER_BYTE;
                    end else begin
                        next_state <= READ_WAIT_2;
                    end
                end

                READ_WAIT_FOR_LOWER_BYTE: begin
                    register_enable <= 1'b0;
                    iovalue <= 8'b00000000;  
                    if (lower_byte_in) begin
                        data_out[7:0] <= data_input_pins;
                        next_state <= READ_LOWER_BYTE;
                    end else begin
                        next_state <= READ_WAIT_FOR_LOWER_BYTE;
                    end
                end

                READ_LOWER_BYTE: begin
                    data_out[7:0] <= data_input_pins;
                    next_state <= READ_WAIT_FOR_UPPER_BYTE;
                end

                READ_WAIT_FOR_UPPER_BYTE: begin
                    if (upper_byte_in) begin
                        next_state <= READ_UPPER_BYTE;
                    end else begin
                        next_state <= READ_WAIT_FOR_UPPER_BYTE;
                    end
                end

                READ_UPPER_BYTE: begin
                    data_out[15:8] <= data_input_pins;
                    next_state <= READ_COMPLETE;
                end

                READ_COMPLETE: begin
                    read_enable <= 1'b0;
                    memory_ready <= 1'b1;
                    next_state <= IDLE;
                end

                // UART Receive Operation - Write Address Lower Byte
                UART_RECEIVE_ADDRESS: begin
                    iovalue <= 8'b11111111;  // Set all uio pins to output mode
                    register_enable <= 1'b1;  // Enable register
                    lower_bit <= 1'b1;  // Indicate lower byte
                    upper_bit <= 1'b0;  // Indicate not upper byte
                    data_output_pins <= uart_memory_address[7:0];  // Output lower byte of address
                    next_state <= UART_WAIT_LOWER_BYTE;  // Wait for the lower byte write to complete
                end

                // UART Wait for Lower Byte Write to Complete
                UART_WAIT_LOWER_BYTE: begin
                    if (wait_counter >= WAIT_CYCLES) begin
                        next_state <= UART_RECEIVE_ADDRESS_UPPER;  // Proceed to upper byte
                    end else begin
                        next_state <= UART_WAIT_LOWER_BYTE;  // Continue waiting
                    end
                end

                // UART Receive Operation - Write Address Upper Byte
                UART_RECEIVE_ADDRESS_UPPER: begin
                    lower_bit <= 1'b0;  // Indicate not lower byte
                    upper_bit <= 1'b1;  // Indicate upper byte
                    data_output_pins <= uart_memory_address[15:8];  // Output upper byte of address
                    next_state <= UART_WAIT_UPPER_BYTE;  // Wait for the upper byte write to complete
                end

                // UART Wait for Upper Byte Write to Complete
                UART_WAIT_UPPER_BYTE: begin
                    if (wait_counter >= WAIT_CYCLES) begin
                        next_state <= UART_RECEIVE_DATA;  // Proceed to write data
                    end else begin
                        next_state <= UART_WAIT_UPPER_BYTE;  // Continue waiting
                    end
                end

                // UART Receive Operation - Write Data
                UART_RECEIVE_DATA: begin
                    register_enable <= 1'b0;  // Disable register for data write
                    lower_bit <= 1'b1;  // Set to write lower byte of data
                    upper_bit <= 1'b0;  // Indicate not upper byte
                    data_output_pins <= data_received;  // Output the received UART data
                    write_enable <= 1'b1;
                    next_state <= UART_WAIT_DATA_WRITE;  // Wait for the data write to complete
                end

                // UART Wait for Data Write to Complete
                UART_WAIT_DATA_WRITE: begin
                    if (write_complete) begin  // Ensure data write is complete
                       write_enable <= 1'b0;
                        next_state <= READ_COMPLETE;  // Go to read complete state or next appropriate state
                    end else begin
                        next_state <= UART_WAIT_DATA_WRITE;  // Continue waiting
                    end
                end

                default: begin
                    next_state <= IDLE; 
                end
            endcase
        end
    end
endmodule
