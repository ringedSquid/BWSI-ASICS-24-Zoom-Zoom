#include "x3q16_ruleset.asm"

ld 0x1, r3
ld 0x1, r2 
add r3, r2, r2
str r2, 0xff
jmpi 0xffff

