#include "x3q16_ruleset.asm"
#include "mainlib.asm"
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

	mov 0xffff, r3
	mov 0x0000, r4
	or r3, r4, r3
	str r3, 0xf4

	mov 0xf0f0, r3
	mov 0x00ff, r4
	and r3, r4, r3
	str r3, 0xf5
	
	mov 0xffff, r3
	not r3, r3
	str r3, 0xf6

	mov 0x0001, r3
	shl r3, r3
	str r3, 0xf7

	mov 0x0002, r3
	shr r3, r3
	str r3, 0xf8



	jmpi end
















