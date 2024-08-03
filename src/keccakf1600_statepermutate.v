module keccak_alu (
    input [64*5-1:0] registers,
    input [2:0] mode,
    output reg [63:0] keccak_output
);

  function [63:0] ROL(input [63:0] a, input [5:0] offset);
    begin
      ROL = (a << offset) ^ (a >> (64 - offset));
    end
  endfunction

  always @* begin
    case (mode)
      3'b000: begin  // kxorinvand
        keccak_output = registers[0*64+:64] ^ ((~registers[1*64+:64]) & registers[2*64+:64]);
      end
      3'b001: begin  // ktheta
        keccak_output = registers[0*64+:64] ^ registers[2*64+:64] ^ registers[3*64+:64] ^ registers[4*64+:64];
      end
      3'b010: begin  // krol
        keccak_output = registers[0*64+:64] ^ ROL(registers[1*64+:64], registers[2*64+:64]);
      end
      3'b011: begin  // kxor
        keccak_output = registers[0*64+:64] ^ registers[1*64+:64];
      end
      default: keccak_output = 0;
    endcase
  end
endmodule
