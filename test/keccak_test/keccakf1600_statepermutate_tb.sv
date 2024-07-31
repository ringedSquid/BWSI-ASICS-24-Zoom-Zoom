/* 
Testbench is supposed to try testing the keccakf1600_statepermutate file, not really working yet.
*/
module keccakf1600_statepermutate_tb;
  reg clk;
  reg rstn;
  reg [63:0] din [24:0];
  wire [63:0] dout [24:0];

  keccakf1600_statepermutate uut (
    .clk(clk),
    .rstn(rstn),
    .din(din),
    .dout(dout)
  );

  always #5 clk = ~clk;  

  initial begin
    clk = 0;
    rstn = 0;
    for(int i = 0; i <25; i++) begin
      din[i] = 64'h0;
    end

    #10 rstn = 1;  

    din[0] = 64'h0000000000000001;
    din[1] = 64'h0000000000000001;
    din[2] = 64'h0000000000000001;
    din[3] = 64'h0000000000000001;
    din[4] = 64'h0000000000000001;
    din[5] = 64'h0000000000000001;
    din[6] = 64'h0000000000000001;
    din[7] = 64'h0000000000000001;
    din[8] = 64'h0000000000000001;
    din[9] = 64'h0000000000000001;
    din[10] = 64'h0000000000000001;
    din[11] = 64'h0000000000000001;
    din[12] = 64'h0000000000000001;
    din[13] = 64'h0000000000000001;
    din[14] = 64'h0000000000000001;
    din[15] = 64'h0000000000000001;
    din[16] = 64'h0000000000000001;
    din[17] = 64'h0000000000000001;
    din[18] = 64'h0000000000000001;
    din[19] = 64'h0000000000000001;
    din[20] = 64'h0000000000000001;
    din[21] = 64'h0000000000000001;
    din[22] = 64'h0000000000000001;
    din[23] = 64'h0000000000000001;
    din[24] = 64'h0000000000000001;

    #100;

    $display("dout[0] = %h", dout[0]);
    $display("dout[1] = %h", dout[1]);

    $stop;
  end
endmodule
