#include "x3q16_ruleset.asm"
#include "pooplib.asm"
init:
	jmpi main
end:
	jmpi 0xffff
main:
	mov 0x1, r3
	mov 0x1, r4
	add r3, r4, r3
	str r3, 0xf1
	jmpi end
















