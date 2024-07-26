//BHE, BLE, and CS Always set to High
module ram_16bit (
    input wire clk,              
    input wire we,   //write enable
    input wire oe,   //output enable
    input wire [17:0] addr, //bus (256k locations)
    inout wire [15:0] data  //io pin 
);

    reg [15:0] memory [0:262143];
    reg [15:0] dout;

    wire data_enable = !we && oe; 

    assign data = data_enable ? dout : 16'bz;
    always @(posedge clk) begin
        if (we) begin
            memory[addr] <= data; // if write enable is high, write data to memory
        end else if (oe) begin
            dout <= memory[addr]; // if write enable is low and output enable is high, read data from memory
        end
    end
endmodule