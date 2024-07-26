module ram_16bit (
    input wire clk,               
    input wire we,   //enable
    input wire [17:0] addr, //bus (256 locations)
    inout wire [15:0] data  //io pin 
);

    reg [15:0] memory [0:262143];
    reg [15:0] dout;
    reg [15:0] din;

    wire data_enable = !we;  //not sure what this does but apparently necessary

    assign data = data_enable ? dout : 16'bz;
    always @(posedge clk) begin
        if (we) begin
            memory[addr] <= data; //if write high write data to memory
        end else begin
            dout <= memory[addr]; //else output memory to io
        end
    end
endmodule
