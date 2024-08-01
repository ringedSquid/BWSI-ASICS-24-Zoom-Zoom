module cordic_atan (
    input wire signed [15:0] x_in,
    input wire signed [15:0] y_in,
    output reg signed [15:0] atan_out
);
    // Parameters
    parameter ITERATIONS = 7;  // Number of iterations

    // CORDIC gain K and arctan table (FP16 format)
    reg signed [15:0] atan_table [0:ITERATIONS-1];
    initial begin
        atan_table[0]  = 16'b0011101001001000; //(0.7853981634)
        atan_table[1]  = 16'b0011011101101011; //(0.463647609)
        atan_table[2]  = 16'b0011001111010110; //(0.2449786631)
        atan_table[3]  = 16'b0010111111110101; //(0.1243549945)
        atan_table[4]  = 16'b0010101111111101; //(0.06241881)
        atan_table[5]  = 16'b0010011111111111; //(0.0312398334)
        atan_table[6]  = 16'b0010001111111111; //(0.0156237286)
    end

    // Registers for iteration
    reg signed [15:0] x, y, z;
    reg [3:0] i;

    always @* begin
        //Initialize with input values at the beginning of the calculation
        x = x_in;
        y = y_in;
        z = 0;

        //Cordic iteration
        for (i = 0; i < ITERATIONS; i = i + 1) begin
                if (y > 0) begin
                    x = x + (y >>> i);
                    y = y - (x >>> i);
                    z = z + atan_table[i];
                end else begin
                    x = x - (y >>> i);
                    y = y + (x >>> i);
                    z = z - atan_table[i];
                end
            end
            
            atan_out = z;
        end
endmodule
