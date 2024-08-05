#include "x3q16_ruleset.asm"

#once
#ruledef 
{
	{value: u16}			   			=> value`16
	mov {r1: register}, {r2: register} 			=> asm { add {r1}, r0, {r2} }
	mov {value: u16}, {ro: register}   			=> {
									asm { ldi value[15:8] @ 0x0`1, r2 } @ 
									asm { addi {ro}, value[7:0] }
					      			}
	not {r1: register}, {ro: register} 			=> asm { nand {r1}, {r1}, {ro} }
	and {r1: register}, {r2: register}, {ro: register} 	=>  { 
									asm { nand {r1}, {r2}, {ro} } @
									asm { not {ro}, {ro} }
								}
	or {r1: register}, {r2: register}, {ro: register} 	=> {
									asm { not {r1}, {r1} } @
									asm { not {r2}, {r2} } @
									asm { nand {r1}, {r2}, {ro}}
								}
	xor {r1: register}, {r2: register}, {ro: register} 	=> {
									asm { nand {r1}, {r2}, {ro} } @
									asm { nand {r1}, {ro}, {r1} } @	
									asm { nand {r2}, {ro}, {r2} } @
									asm { nand {r1}, {r2}, {ro} } 
								}
}
