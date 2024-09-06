module uart_tx (
        input clk,
        input reset,
        input [12:0] data,
        input send,
        input set,
        output reg busy,
        output reg tx_reg
    );

    localparam UART_SPEED_DEFAULT = 13'b1100001101010;

    reg [12:0] cycles_per_bit, cycle_counter;
    reg [7:0] data_sending;
    reg [2:0] bit_counter;
    reg [1:0] stage;
    //reg tx_reg;
    //assign tx = tx_reg;

    always @(posedge clk or posedge reset)
    begin
        if (reset) begin
            busy <= 1'b0;
            data_sending <= 8'h0;
            bit_counter <= 3'b0;
            tx_reg <= 1'b1;
            cycles_per_bit <= UART_SPEED_DEFAULT;
            cycle_counter <= 16'h0;
            stage <= 2'b00;
        end else if (set) begin
            cycles_per_bit <= data;
        end else begin
            case (stage)
                2'b00: begin
                    if (send) begin
                        tx_reg <= 1'b0;
                        cycle_counter <= 16'h0000;
                        stage <= 2'b01;
                        data_sending <= data[7:0];
                        busy <= 1'b1;
                    end
                end
                2'b01: begin
                    if (cycle_counter == cycles_per_bit) begin
                        cycle_counter <= 16'h0000;
                        tx_reg <= data_sending[bit_counter];
                        if (bit_counter == 3'b111) begin
                            stage <= 2'b10;
                        end else begin
                            bit_counter <= bit_counter + 3'b001;
                        end    
                    end else cycle_counter <= cycle_counter + 16'h0001;
                end
                2'b10: begin
                    if (cycle_counter == cycles_per_bit) begin
                        bit_counter <= 3'b000;
                        tx_reg <= 1'b1;
                        cycle_counter <= 16'h0000;
                        if (bit_counter == 3'b000) begin
                            busy <= 1'b0;
                            stage <= 2'b00;
                        end
                    end else cycle_counter <= cycle_counter + 16'h0001;
                end
            endcase
        end
    end
endmodule
