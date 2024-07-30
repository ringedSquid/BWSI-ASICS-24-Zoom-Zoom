// module keccakf1600_statepermutate(
// 	input clk,
// 	input rstn,
// 	input [64*24-1:0] din, 
// 	output reg [64*24-1:0] dout);

// 	reg [64*24-1:0] state;
// 	reg [64*24-1:0] next_state;
// 	reg [4:0] state_round;
// 	reg [4:0] next_state_round;
// 	reg [63:0] const_1;
// 	reg [63:0] const_2;

// localparam [64*24-1:0] round_constants = {
//     64'h0000000000000001,
//     64'h0000000000008082,
//     64'h800000000000808a,
//     64'h8000000080008000,
//     64'h000000000000808b,
//     64'h0000000080000001,
//     64'h8000000080008081,
//     64'h8000000000008009,
//     64'h000000000000008a,
//     64'h0000000000000088,
//     64'h0000000080008009,
//     64'h000000008000000a,
//     64'h000000008000808b,
//     64'h800000000000008b,
//     64'h8000000000008089,
//     64'h8000000000008003,
//     64'h8000000000008002,
//     64'h8000000000000080,
//     64'h000000000000800a,
//     64'h800000008000000a,
//     64'h8000000080008081,
//     64'h8000000000008080,
//     64'h0000000080000001,
//     64'h8000000080008008
// };

// keccak_round k_round (.instate(state), .round_constant1(const_1), .round_constant2(const_2), .outstate(next_state));

// 	always @ (posedge clk) begin
// 		if (!rstn)
// 		begin
// 			if(state_round == 0) begin
// 				state <= din;
// 			end else if(state_round == 5'd23) begin
// 				dout <= state;
// 			end
// 			state_round <= next_state_round;
// 			state <= next_state;
// 		end
// 	end

// 	always @* begin
// 			const_1 = round_constants[state_round*64+:64];
// 			const_2 = round_constants[(state_round+5'd1)*64+:64];
// 	if (state_round == 5'd23) begin
// 				next_state_round = 0;
// 			end else
// 				next_state_round = state_round + 5'd2;
// 	end
// endmodule

module keccak_round(
	input [64*24-1:0] instate,
	input [63:0] round_constant1,
	// input [63:0] round_constant2,
	output reg [64*24-1:0] outstate);

function [63:0] ROL(input [63:0] a, input [63:0] offset);
	begin
		ROL = (a << offset)^(a >> (64 - offset));
	end
endfunction

reg [63:0] state [24:0];
`define ABA state[0]
`define ABE state[1]
`define ABI state[2]
`define ABO state[3]
`define ABU state[4]
`define AGA state[5]
`define AGE state[6]
`define AGI state[7]
`define AGO state[8]
`define AGU state[9]
`define AKA state[10]
`define AKE state[11]
`define AKI state[12]
`define AKO state[13]
`define AKU state[14]
`define AMA state[15]
`define AME state[16]
`define AMI state[17]
`define AMO state[18]
`define AMU state[19]
`define ASA state[20]
`define ASE state[21]
`define ASI state[22]
`define ASO state[23]
`define ASU state[24]

reg [63:0] b_state [4:0];

`define BCA b_state[0]
`define BCE b_state[1]
`define BCI b_state[2]
`define BCO b_state[3]
`define BCU b_state[4]

reg [63:0] d_state [4:0];

`define DA d_state[0]
`define DE d_state[1]
`define DI d_state[2]
`define DO d_state[3]
`define DU d_state[4]

`define EBA outstate[0*64+:64]
`define EBE outstate[1*64+:64]
`define EBI outstate[2*64+:64]
`define EBO outstate[3*64+:64]
`define EBU outstate[4*64+:64]
`define EGA outstate[5*64+:64]
`define EGE outstate[6*64+:64]
`define EGI outstate[7*64+:64]
`define EGO outstate[8*64+:64]
`define EGU outstate[9*64+:64]
`define EKA outstate[10*64+:64]
`define EKE outstate[11*64+:64]
`define EKI outstate[12*64+:64]
`define EKO outstate[13*64+:64]
`define EKU outstate[14*64+:64]
`define EMA outstate[15*64+:64]
`define EME outstate[16*64+:64]
`define EMI outstate[17*64+:64]
`define EMO outstate[18*64+:64]
`define EMU outstate[19*64+:64]
`define ESA outstate[20*64+:64]
`define ESE outstate[21*64+:64]
`define ESI outstate[22*64+:64]
`define ESO outstate[23*64+:64]
`define ESU outstate[24*64+:64]

integer i;

always @* begin
	for (i=0; i<=24; i=i+1) begin
    state[i] = instate[64*i +: 64];
  end

	// prepareTheta
	`BCA = `ABA ^ `AGA ^ `AKA ^ `AMA ^ `ASA;
	`BCE = `ABE ^ `AGE ^ `AKE ^ `AME ^ `ASE;
	`BCI = `ABI ^ `AGI ^ `AKI ^ `AMI ^ `ASI;
	`BCO = `ABO ^ `AGO ^ `AKO ^ `AMO ^ `ASO;
	`BCU = `ABU ^ `AGU ^ `AKU ^ `AMU ^ `ASU;

	//thetaRhoPiChiIotaPrepareTheta(round, A, E)
	`DA = `BCU ^ ROL(`BCE, 1);
	`DE = `BCA ^ ROL(`BCI, 1);
	`DI = `BCE ^ ROL(`BCO, 1);
	`DO = `BCI ^ ROL(`BCU, 1);
	`DU = `BCO ^ ROL(`BCA, 1);

	`ABA = `ABA ^ `DA;
	`BCA = `ABA;
	`AGE = `AGE ^ `DE;
	`BCE = ROL(`AGE, 44);
	`AKI = `AKI ^ `DI;
	`BCI = ROL(`AKI, 43);
	`AMO = `AMO ^ `DO;
	`BCO = ROL(`AMO, 21);
	`ASU = `DU ^ `ASU;
	`BCU = ROL(`ASU, 14);
	`EBA = `BCA ^ ((~`BCE)& `BCI);
	`EBA = `EBA ^ round_constant1;
	`EBE = `BCE ^((~`BCI)& `BCO);
	`EBI = `BCI ^((~`BCO)& `BCU);
	`EBO = `BCO ^((~`BCU)& `BCA);
	`EBU = `BCU ^((~`BCA)& `BCE);

	`ABO = `ABO ^ `DO;
	`BCA = ROL(`ABO, 28);
	`AGU = `AGU ^ `DU;
	`BCE = ROL(`AGU, 20);
	`AKA = `AKA ^ `DA;
	`BCI = ROL(`AKA, 3);
	`AME = `AME ^ `DE;
	`BCO = ROL(`AME, 45);
	`ASI = `ASI ^ `DI;
	`BCU = ROL(`ASI, 61);
	`EGA = `BCA ^((~`BCE)& `BCI);
	`EGE = `BCE ^((~`BCI)& `BCO);
	`EGI = `BCI ^((~`BCO)& `BCU);
	`EGO = `BCO ^((~`BCU)& `BCA);
	`EGU = `BCU ^((~`BCA)& `BCE);

	`ABE = `ABE ^ `DE;
	`BCA = ROL(`ABE, 1);
	`AGI = `AGI ^ `DI;
	`BCE = ROL(`AGI, 6);
	`AKO = `AKO ^ `DO;
	`BCI = ROL(`AKO, 25);
	`AMU = `AMU ^ `DU;
	`BCO = ROL(`AMU, 8);
	`ASA = `ASA ^ `DA;
	`BCU = ROL(`ASA, 18);
	`EKA = `BCA ^((~`BCE)& `BCI);
	`EKE = `BCE ^((~`BCI)& `BCO);
	`EKI = `BCI ^((~`BCO)& `BCU);
	`EKO = `BCO ^((~`BCU)& `BCA);
	`EKU = `BCU ^((~`BCA)& `BCE);

	`ABU = `ABU ^ `DU;
	`BCA = ROL(`ABU, 27);
	`AGA = `AGA ^ `DA;
	`BCE = ROL(`AGA, 36);
	`AKE = `AKE ^ `DE;
	`BCI = ROL(`AKE, 10);
	`AMI = `AMI ^ `DI;
	`BCO = ROL(`AMI, 15);
	`ASO = `ASO ^ `DO;
	`BCU = ROL(`ASO, 56);
	`EMA = `BCA ^((~`BCE)& `BCI);
	`EME = `BCE ^((~`BCI)& `BCO);
	`EMI = `BCI ^((~`BCO)& `BCU);
	`EMO = `BCO ^((~`BCU)& `BCA);
	`EMU = `BCU ^((~`BCA)& `BCE);

	`ABI = `ABI ^ `DI;
	`BCA = ROL(`ABI, 62);
	`AGO = `AGO ^ `DO;
	`BCE = ROL(`AGO, 55);
	`AKU = `AKU ^ `DU;
	`BCI = ROL(`AKU, 39);
	`AMA = `AMA ^ `DA;
	`BCO = ROL(`AMA, 41);
	`ASE = `ASE ^ `DE;
	`BCU = ROL(`ASE, 2);
	`ESA = `BCA ^((~`BCE)& `BCI);
	`ESE = `BCE ^((~`BCI)& `BCO);
	`ESI = `BCI ^((~`BCO)& `BCU);
	`ESO = `BCO ^((~`BCU)& `BCA);
	`ESU = `BCU ^((~`BCA)& `BCE);

	// // -----------------------------------------------------------------------------------------

	// // prepareTheta
	// `BCA = `EBA ^ `EGA ^ `EKA ^ `EMA ^ `ESA;
	// `BCE = `EBE ^ `EGE ^ `EKE ^ `EME ^ `ESE;
	// `BCI = `EBI ^ `EGI ^ `EKI ^ `EMI ^ `ESI;
	// `BCO = `EBO ^ `EGO ^ `EKO ^ `EMO ^ `ESO;
	// `BCU = `EBU ^ `EGU ^ `EKU ^ `EMU ^ `ESU;

	// // thetaRhoPiChiIotaPerpareTheta(round +1, E, A)
	// `DA = `BCU ^ ROL(`BCE, 1);
	// `DE = `BCA ^ ROL(`BCI, 1);
	// `DI = `BCE ^ ROL(`BCO, 1);
	// `DO = `BCI ^ ROL(`BCU, 1);
	// `DU = `BCO ^ ROL(`BCA, 1);

	// `EBA = `EBA ^ `DA;
	// `BCA = `EBA;
	// `EGE = `EGE ^ `DE;
	// `BCE = ROL(`EGE, 44);
	// `EKI = `EKI ^ `DI;
	// `BCI = ROL(`EKI, 43);
	// `EMO = `EMO ^ `DO;
	// `BCO = ROL(`EMO, 21);
	// `ESU = `ESU ^ `DU;
	// `BCU = ROL(`ESU, 14);
	// `ABA = `BCA ^((~`BCE)& `BCI);
	// `ABA = `ABA ^ round_constant2;
	// `ABE = `BCE ^((~`BCI)& `BCO);
	// `ABI = `BCI ^((~`BCO)& `BCU);
	// `ABO = `BCO ^((~`BCU)& `BCA);
	// `ABU = `BCU ^((~`BCA)& `BCE);

	// `EBO = `EBO ^ `DO;
	// `BCA = ROL(`EBO, 28);
	// `EGU = `EGU ^ `DU;
	// `BCE = ROL(`EGU, 20);
	// `EKA = `EKA ^ `DA;
	// `BCI = ROL(`EKA, 3);
	// `EME = `EME ^ `DE;
	// `BCO = ROL(`EME, 45);
	// `ESI = `ESI ^ `DI;
	// `BCU = ROL(`ESI, 61);
	// `AGA = `BCA ^((~`BCE)& `BCI);
	// `AGE = `BCE ^((~`BCI)& `BCO);
	// `AGI = `BCI ^((~`BCO)& `BCU);
	// `AGO = `BCU ^((~`BCU)& `BCA);
	// `AGU = `BCU ^((~`BCA)& `BCE);

	// `EBE = `EBE ^ `DE;
	// `BCA = ROL(`EBE, 1);
	// `EGI = `EGI ^ `DI;
	// `BCE = ROL(`EGI, 6);
	// `EKO = `EKO ^ `DO;
	// `BCI = ROL(`EKO, 25);
	// `EMU = `EMU ^ `DU;
	// `BCO = ROL(`EMU, 0);
	// `ESA = `ESA ^ `DA;
	// `BCU = ROL(`ESA, 10);
	// `AKA = `BCA ^((~`BCE)& `BCI);
	// `AKE = `BCE ^((~`BCI)& `BCO);
	// `AKI = `BCI ^((~`BCO)& `BCU);
	// `AKO = `BCO ^((~`BCU)& `BCA);
	// `AKU = `BCU ^((~`BCA)& `BCE);

	// `EBU = `EBU ^ `DU;
	// `BCA = ROL(`EBU, 27);
	// `EGA = `EGA ^ `DA;
	// `BCE = ROL(`EGA, 36);
	// `EKE = `EKE ^ `DE;
	// `BCI = ROL(`EKE, 10);
	// `EMI = `EMI ^ `DI;
	// `BCO = ROL(`EMI, 15);
	// `ESO = `ESO ^ `DO;
	// `BCU = ROL(`ESO, 56);
	// `AMA = `BCA ^((~`BCE)& `BCI);
	// `AME = `BCE ^((~`BCI)& `BCO);
	// `AMI = `BCI ^((~`BCO)& `BCU);
	// `AMO = `BCO ^((~`BCU)& `BCA);
	// `AMU = `BCU ^((~`BCA)& `BCE);

	// `EBI = `EBI ^ `DI;
	// `BCA = ROL(`EBI, 62);
	// `EGO = `EGO ^ `DO;
	// `BCE = ROL(`EGO, 55);
	// `EKU = `EKU ^ `DU;
	// `BCI = ROL(`EKU, 39);
	// `EMA = `EMA ^ `DA;
	// `BCO = ROL(`EMA, 41);
	// `ESE = `ESE ^ `DE;
	// `BCU = ROL(`ESE, 2);
	// `ASA = `BCA ^((~`BCE)& `BCI);
	// `ASE = `BCE ^((~`BCI)& `BCO);
	// `ASI = `BCI ^((~`BCO)& `BCU);
	// `ASO = `BCO ^((~`BCU)& `BCA);
	// `ASU = `BCU ^((~`BCA)& `BCE);
end

endmodule
