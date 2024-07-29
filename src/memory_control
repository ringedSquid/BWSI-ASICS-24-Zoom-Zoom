module memory_control (
    input wire clk,             // clock signal
    input wire reset,           // reset signal
    input wire [15:0] request_address, // address for the next memory read or write
    input wire request_type,    // 0 for read, 1 for write
    input wire request,         // enable request
    input wire [15:0] data_out, // data to be written to memory
    
    output reg [15:0] memory_in, // data read from memory
    output reg memory_ready,     // read ready
    output reg write_complete    // write complete
);

    wire [15:0] ram_data;
    reg [15:0] data_to_ram; // reg for ram wrote
    reg ram_we, ram_oe;
    reg [15:0] current_address; // reg for req address

    // ram my friend
    ram_16bit RAM (
        .clk(clk),
        .we(ram_we),
        .oe(ram_oe),
        .addr(current_address),
        .data(ram_we ? data_to_ram : 16'bz) 
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            memory_ready <= 1'b0;
            write_complete <= 1'b0;
            ram_we <= 1'b0;
            ram_oe <= 1'b0;
            current_address <= 16'b0;
        end else begin
            if (request) begin
                current_address <= request_address;

                if (request_type) begin // write request
                    ram_we <= 1'b1;
                    ram_oe <= 1'b0;
                    data_to_ram <= data_out;
                    memory_ready <= 1'b0;
                    write_complete <= 1'b0;
                end 
                
                else begin // read request
                    ram_we <= 1'b0;
                    ram_oe <= 1'b1;
                    memory_ready <= 1'b0;
                    write_complete <= 1'b0;
                end
            end else begin
                if (ram_we) begin // write complete
                    write_complete <= 1'b1;
                    ram_we <= 1'b0;
                end 
                
                else if (ram_oe) begin // read complete
                    memory_ready <= 1'b1;
                    memory_in <= ram_data;
                    ram_oe <= 1'b0;
                end 
                
                else begin // nothing
                    memory_ready <= 1'b0;
                    write_complete <= 1'b0;
                end
            end
        end
    end
endmodule
