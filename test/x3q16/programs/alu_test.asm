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
	
	mov 0x2, r3
	mov 0x2, r4
	mult r3, r4, r3
	str r3, 0xf2

	mov 0x0f, r3
	mov 0xf0, r4
	nand r3, r4, r3
	str r3, 0xf3

	jmpi end
















