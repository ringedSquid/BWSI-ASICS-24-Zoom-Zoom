#include "x3q16_ruleset.asm"
#include "pooplib.asm"
init:
	jmpi main
end:
	jmpi 0xffff
main:
	mov 0x1, r3 ;add
	mov 0x1, r4
	add r3, r4, r3
	str r3, 0xf1

	mov k0_0, r2
	mov k0_1, r3
	mov k0_2, r4
	mov k0_3, r5
	
	mov k1_0, r6
	mov k1_1, r7

	ldkrc l, k0, r2
	ldkrc lm, k0, r3
	ldkrc um, k0, r4
	ldkrc u, k0, r5

	ldkrc l, k1, r6
	ldkrc lm, k1, r7

	mov k2_0, r2
	mov k2_1, r3
	mov k2_2, r4
	mov k2_3, r5
	
	mov k1_2, r6
	mov k1_3, r7

	ldkrc l, k2, r2
	ldkrc lm, k2, r3
	ldkrc um, k2, r4
	ldkrc u, k2, r5

	ldkrc um, k1, r6
	ldkrc u, k1, r7

	mov k3_0, r2
	mov k3_1, r3
	mov k3_2, r4
	mov k3_3, r5

	ldkrc l, k3, r2
	ldkrc lm, k3, r3
	ldkrc um, k3, r4
	ldkrc u, k3, r5

	kxorinvand
	ktheta
	krol
	kxor	

	jmpi end

k0_0:
0x456a
k0_1:
0x456a
k0_2:
0x456a
k0_3:
0x456a

k1_0:
0x2000
k1_1:
0x2000
k1_2:
0x2000
k1_3:
0x2000

k2_0:
0x2120
k2_1:
0x2120
k2_2:
0x2120
k2_3:
0x2120

k3_0:
0x45ca
k3_1:
0x45ca
k3_2:
0x45ca
k3_3:
0x45ca
