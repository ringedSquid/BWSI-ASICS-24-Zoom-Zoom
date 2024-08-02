module memory_controller (
    input clk,
    input reset,

    // Interface with x3q16
    input [15:0] request_address,
    input request_type, // 0 for read, 1 for write
    input request,
    input [15:0] data_out,
    output reg [15:0] data_in,
    output reg memory_ready,
    output reg write_complete,

    // arduino output
    output reg write_enable,
    output reg register_enable,
    output reg read_enable,
    output reg lower_bit,
    output reg upper_bit,

    //arduino input
    input lower_byte_in,
    input upper_byte_in,

    inout [7:0] data_pins /io pins
);

    parameter IDLE = 4'b0000;
    parameter WRITE_SETUP = 4'b0001;
    parameter WRITE_WAIT_1 = 4'b0010;
    parameter WRITE_ADDRESS_UPPER = 4'b0011;
    parameter WRITE_WAIT_2 = 4'b0100;
    parameter LOAD_DATA_LOWER = 4'b0101;
    parameter WRITE_WAIT_3 = 4'b0110;
    parameter LOAD_DATA_UPPER = 4'b0111;
    parameter WRITE_WAIT_4 = 4'b1000;
    parameter WRITE_COMPLETE = 4'b1001;
    parameter READ_SETUP = 4'b1010;
    parameter READ_WAIT_1 = 4'b1011;
    parameter READ_ADDRESS_UPPER = 4'b1100;
    parameter READ_WAIT_2 = 4'b1101;
    parameter READ_WAIT_FOR_LOWER_BYTE = 4'b1110;
    parameter READ_LOWER_BYTE = 4'b1111;
    parameter READ_WAIT_FOR_UPPER_BYTE = 5'b10000;
    parameter READ_UPPER_BYTE = 5'b10001;
    parameter READ_COMPLETE = 5'b10010;

    reg [4:0] state, next_state;

    reg [7:0] data_bus;
    reg data_direction; 

    assign data_pins = data_direction ? data_bus : 8'bZ; //so i can use io for both in and out

    // Counters to create delay/wait cycles
    reg [5:0] wait_counter; 
    parameter WAIT_CYCLES = 6'd4; 

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
            data_direction <= 1'b0;
            data_bus <= 8'b0;
            data_in <= 16'b0;
            wait_counter <= 6'b0;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        memory_ready = 1'b0;
        write_complete = 1'b0;
        write_enable = 1'b0;
        read_enable = 1'b0;
        register_enable = 1'b0;
        lower_bit = 1'b0;
        upper_bit = 1'b0;
        data_direction = 1'b0;
        data_bus = 8'b0;
        next_state = state; 

        case (state)
            IDLE: begin
                lower_bit = 1'b0;
                upper_bit = 1'b0;
                if (request && request_type == 1'b1) begin
                    next_state = WRITE_SETUP;
                end else if (request && request_type == 1'b0) begin
                    next_state = READ_SETUP;
                end
            end

            // Write Operation
            WRITE_SETUP: begin
                write_enable = 1'b1;
                register_enable = 1'b1;
                lower_bit = 1'b1;
                data_bus = request_address[7:0]; // Load lower bits of address
                data_direction = 1'b1;
                next_state = WRITE_WAIT_1;
            end

            WRITE_WAIT_1: begin
                if (wait_counter >= WAIT_CYCLES) begin
                    next_state = WRITE_ADDRESS_UPPER;
                end else begin
                    next_state = WRITE_WAIT_1;
                end
            end

            WRITE_ADDRESS_UPPER: begin
                lower_bit = 1'b0;
                upper_bit = 1'b1;
                data_bus = request_address[15:8]; // Load upper bits of address
                data_direction = 1'b1;
                next_state = WRITE_WAIT_2;
            end

            WRITE_WAIT_2: begin
                if (wait_counter >= WAIT_CYCLES) begin
                    next_state = LOAD_DATA_LOWER;
                end else begin
                    next_state = WRITE_WAIT_2;
                end
            end

            LOAD_DATA_LOWER: begin
                register_enable = 1'b0;
                lower_bit = 1'b1;
                upper_bit = 1'b0;
                data_bus = data_out[7:0]; // Load lower byte of data
                data_direction = 1'b1;
                next_state = WRITE_WAIT_3;
            end

            WRITE_WAIT_3: begin
                if (wait_counter >= WAIT_CYCLES) begin
                    next_state = LOAD_DATA_UPPER;
                end else begin
                    next_state = WRITE_WAIT_3;
                end
            end

            LOAD_DATA_UPPER: begin
                lower_bit = 1'b0;
                upper_bit = 1'b1;
                data_bus = data_out[15:8]; // Load upper byte of data
                data_direction = 1'b1;
                next_state = WRITE_WAIT_4;
            end

            WRITE_WAIT_4: begin
                if (wait_counter >= WAIT_CYCLES) begin
                    next_state = WRITE_COMPLETE;
                end else begin
                    next_state = WRITE_WAIT_4;
                end
            end

            WRITE_COMPLETE: begin
                write_enable = 1'b0;
                upper_bit = 1'b0;
                write_complete = 1'b1;
                next_state = IDLE;
            end

            // Read Operation
            READ_SETUP: begin
                read_enable = 1'b1;
                register_enable = 1'b1;
                lower_bit = 1'b1;
                data_bus = request_address[7:0]; // Load lower bits of address
                data_direction = 1'b1;
                next_state = READ_WAIT_1;
            end

            READ_WAIT_1: begin
                if (wait_counter >= WAIT_CYCLES) begin
                    next_state = READ_ADDRESS_UPPER;
                end else begin
                    next_state = READ_WAIT_1;
                end
            end

            READ_ADDRESS_UPPER: begin
                lower_bit = 1'b0;
                upper_bit = 1'b1;
                data_bus = request_address[15:8]; // Load upper bits of address
                data_direction = 1'b1;
                next_state = READ_WAIT_2;
            end

            READ_WAIT_2: begin
                if (wait_counter >= WAIT_CYCLES) begin
                    next_state = READ_WAIT_FOR_LOWER_BYTE;
                end else begin
                    next_state = READ_WAIT_2;
                end
            end

            READ_WAIT_FOR_LOWER_BYTE: begin
                data_direction = 1'b0; // Switch to input mode
                if (lower_byte_in) begin
                    next_state = READ_LOWER_BYTE;
                end else begin
                    next_state = READ_WAIT_FOR_LOWER_BYTE;
                end
            end

            READ_LOWER_BYTE: begin
                data_in[7:0] = data_pins; // Capture lower byte
                next_state = READ_WAIT_FOR_UPPER_BYTE;
            end

            READ_WAIT_FOR_UPPER_BYTE: begin
                if (upper_byte_in) begin
                    next_state = READ_UPPER_BYTE;
                end else begin
                    next_state = READ_WAIT_FOR_UPPER_BYTE;
                end
            end

            READ_UPPER_BYTE: begin
                data_in[15:8] = data_pins; // Capture upper byte
                next_state = READ_COMPLETE;
            end

            READ_COMPLETE: begin
                read_enable = 1'b0;
                memory_ready = 1'b1;
                next_state = IDLE;
            end
        endcase
    end

    // Counter for waiting cycles
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wait_counter <= 6'b0;
        end else if (state == WRITE_WAIT_1 || state == WRITE_WAIT_2 || state == WRITE_WAIT_3 || state == WRITE_WAIT_4 ||
                     state == READ_WAIT_1 || state == READ_WAIT_2) begin
            wait_counter <= wait_counter + 1;
        end else begin
            wait_counter <= 6'b0;
        end
    end
endmodule
