#include "x3q16_ruleset.asm"
#include "pooplib.asm"
jmpi main

main:
	mov 0x1, r3 ;1+1
	mov 0x1, r4
	add r3, r4, r5
	str r5, 0xf1
	jmpi end
	
end:
	jmpi 0xffff
	
















