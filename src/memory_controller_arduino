module memory_control (
    input wire clk,
    input wire reset,
    input wire [15:0] request_address,
    input wire request_type,
    input wire request,
    input wire [15:0] data_out,
    output reg [15:0] memory_in,
    output reg memory_ready,
    output reg write_complete,
    inout wire [7:0] data_pins,
    output reg lower_byte_pin,
    output reg upper_byte_pin,
    output reg [1:0] control_signal_pins,
    output reg request_pin
);

    reg [7:0] lower_byte;
    reg [7:0] upper_byte;
    reg [15:0] current_address;
    reg [7:0] data_out_latched;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            memory_ready <= 1'b0;
            write_complete <= 1'b0;
            current_address <= 16'b0;
            lower_byte_pin <= 1'b0;
            upper_byte_pin <= 1'b0;
            control_signal_pins <= 2'b00;
            request_pin <= 1'b0;
        end else begin
            if (request) begin
                current_address <= request_address;
                request_pin <= 1'b1;
                if (request_type) begin
                    control_signal_pins <= 2'b01;
                    lower_byte_pin <= 1'b1;
                    upper_byte_pin <= 1'b0;
                    data_out_latched <= data_out[7:0];
                    lower_byte_pin <= 1'b0;
                    upper_byte_pin <= 1'b1;
                    data_out_latched <= data_out[15:8];
                    write_complete <= 1'b1;
                    control_signal_pins <= 2'b00;
                    upper_byte_pin <= 1'b0;
                    request_pin <= 1'b0;
                end else begin
                    control_signal_pins <= 2'b10;
                    lower_byte_pin <= 1'b1;
                    upper_byte_pin <= 1'b0;
                    lower_byte = data_pins;
                    lower_byte_pin <= 1'b0;
                    upper_byte_pin <= 1'b1;
                    upper_byte = data_pins;
                    memory_in <= {upper_byte, lower_byte};
                    memory_ready <= 1'b1;
                    control_signal_pins <= 2'b00;
                    upper_byte_pin <= 1'b0;
                    request_pin <= 1'b0;
                end
            end else begin
                memory_ready <= 1'b0;
                write_complete <= 1'b0;
                request_pin <= 1'b0;
            end
        end
    end

    always @(*) begin
        if (control_signal_pins == 2'b01) begin
            if (upper_byte_pin) begin
                data_pins = data_out_latched;
            end else if (lower_byte_pin) begin
                data_pins = data_out_latched;
            end else begin
                data_pins = 8'bz;
            end
        end else begin
            data_pins = 8'bz;
        end
    end

endmodule
*/


//asked chatgpt to add statemachine to improve timing
module memory_control (
    input wire clk,    // clock signal
    input wire reset,         // reset signal
    input wire [15:0] request_address, // address for the next memory read or write
    input wire request_type,  // 0 read 1 write
    input wire request,         // enable request
    input wire [15:0] data_out, // data to be written to memory
    output reg [15:0] memory_in, // data read from memory
    output reg memory_ready,     // read ready
    output reg write_complete,   // write complete
    inout wire [7:0] data_pins,  // 8-bit data bus shared with Arduino
    output reg lower_byte_pin,   // Control signal for lower byte
    output reg upper_byte_pin,   // Control signal for upper byte
    output reg [1:0] control_signal_pins, // 2-bit control signal
    output reg request_pin       // Request signal to Arduino
);

    reg [7:0] lower_byte;
    reg [7:0] upper_byte;
    reg [15:0] current_address;
    reg [7:0] data_out_latched;
    reg [2:0] state;

    localparam IDLE = 3'b000;
    localparam WRITE_LOWER = 3'b001;
    localparam WRITE_UPPER = 3'b010;
    localparam READ_LOWER = 3'b011;
    localparam READ_UPPER = 3'b100;

    assign data_pins = (state == WRITE_LOWER || state == WRITE_UPPER) ? data_out_latched : 8'bz;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            memory_ready <= 1'b0;
            write_complete <= 1'b0;
            current_address <= 16'b0;
            lower_byte_pin <= 1'b0;
            upper_byte_pin <= 1'b0;
            control_signal_pins <= 2'b00;
            request_pin <= 1'b0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    memory_ready <= 1'b0;
                    write_complete <= 1'b0;
                    if (request) begin
                        current_address <= request_address;
                        request_pin <= 1'b1;
                        if (request_type) begin // write request
                            control_signal_pins <= 2'b01;
                            lower_byte_pin <= 1'b1;
                            upper_byte_pin <= 1'b0;
                            data_out_latched <= data_out[7:0];
                            state <= WRITE_LOWER;
                        end else begin // read request
                            control_signal_pins <= 2'b10;
                            lower_byte_pin <= 1'b1;
                            upper_byte_pin <= 1'b0;
                            state <= READ_LOWER;
                        end
                    end
                end
                WRITE_LOWER: begin
                    lower_byte_pin <= 1'b0;
                    upper_byte_pin <= 1'b1;
                    data_out_latched <= data_out[15:8];
                    state <= WRITE_UPPER;
                end
                WRITE_UPPER: begin
                    write_complete <= 1'b1;
                    control_signal_pins <= 2'b00;
                    upper_byte_pin <= 1'b0;
                    request_pin <= 1'b0;
                    state <= IDLE;
                end
                READ_LOWER: begin
                    lower_byte = data_pins;
                    lower_byte_pin <= 1'b0;
                    upper_byte_pin <= 1'b1;
                    state <= READ_UPPER;
                end
                READ_UPPER: begin
                    upper_byte = data_pins;
                    memory_in <= {upper_byte, lower_byte};
                    memory_ready <= 1'b1;
                    control_signal_pins <= 2'b00;
                    upper_byte_pin <= 1'b0;
                    request_pin <= 1'b0;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
