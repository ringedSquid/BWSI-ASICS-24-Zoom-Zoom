#include "x3q16_ruleset.asm"

#once
#ruledef 
{
	{value: u16}			   => value`16
	mov {r1: register}, {r2: register} => asm { add {r1}, r0, {r2} }
	mov {value: u16}, {ro: register}   => {
						asm { ldi value[15:8] @ 0x0`1, r2 } @ 
						asm { addi {ro}, value[7:0] }
					      }
	not {r1: register}, {ro: register} => asm { nand {r1}, {r1}, {ro} }
	
}
