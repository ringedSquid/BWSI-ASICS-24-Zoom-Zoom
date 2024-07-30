// BHE, BLE, and CS Always set to High
module ram_16bit (
    input wire clk,              
    input wire we,   // write enable
    input wire oe,   // read enable
    input wire [15:0] addr, // bus 
    inout wire [15:0] data  // io pin 
);

    reg [15:0] memory [15:0];
    reg [15:0] dout;

    wire data_enable = !we && oe; 

    assign data = data_enable ? dout : 16'bz;

    always @(posedge clk) begin
        if (we) begin
            memory[addr] <= data; // write data to memory
        end 
        
        else if (oe) begin
            dout <= memory[addr]; // read data from memory
        end
    end
endmodule


