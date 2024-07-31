module cordic_atan (
    input wire clk,
    input wire rst,
    input wire signed [15:0] x_in,
    input wire signed [15:0] y_in,
    output reg signed [15:0] atan_out
);
    // Parameters
    parameter ITERATIONS = 12;  // Number of iterations

    // CORDIC gain K and arctan table (Q3.13 format)
    reg signed [15:0] atan_table [0:ITERATIONS-1];
    initial begin
        atan_table[0]  = 16'b0000110010010001; // atan(2^-0) in Q3.13
        atan_table[1]  = 16'b0000011101100100; // atan(2^-1) in Q3.13
        atan_table[2]  = 16'b0000001111101011; // atan(2^-2) in Q3.13
        atan_table[3]  = 16'b0000001001110110; // atan(2^-3) in Q3.13
        atan_table[4]  = 16'b0000000100111110; // atan(2^-4) in Q3.13
        atan_table[5]  = 16'b0000000010100011; // atan(2^-5) in Q3.13
        atan_table[6]  = 16'b0000000001010001; // atan(2^-6) in Q3.13
        atan_table[7]  = 16'b0000000000101000; // atan(2^-7) in Q3.13
        atan_table[8]  = 16'b0000000000010100; // atan(2^-8) in Q3.13
        atan_table[9]  = 16'b0000000000001010; // atan(2^-9) in Q3.13
        atan_table[10] = 16'b0000000000000101; // atan(2^-10) in Q3.13
        atan_table[11] = 16'b0000000000000010; // atan(2^-11) in Q3.13
    end

    // Registers for iteration
    reg signed [15:0] x, y, z;
    reg [3:0] i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x <= 0;
            y <= 0;
            z <= 0;
            atan_out <= 0;
        end else begin
            // Initialize with input values at the beginning of the cycle
            x <= x_in;
            y <= y_in;
            z <= 0;

            for (i = 0; i < ITERATIONS; i = i + 1) begin
                if (y > 0) begin
                    x <= x + (y >>> i);
                    y <= y - (x >>> i);
                    z <= z + atan_table[i];
                end else begin
                    x <= x - (y >>> i);
                    y <= y + (x >>> i);
                    z <= z - atan_table[i];
                end
            end
            atan_out <= z;
        end
    end
endmodule
