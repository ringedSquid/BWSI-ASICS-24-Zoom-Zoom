#once

#bits 16 ;

#subruledef register
{
	r0 => 0x0
	rf => 0x1
	r2 => 0x2
	r3 => 0x3
	r4 => 0x4
	r5 => 0x5
	r6 => 0x6
	r7 => 0x7
}



#ruledef 
{
	nop                                                  	  => 0x0`16

	add     {r1: register}, {r2: register}, {ro: register}    => ro`3 @ r2`3 @ r1`3 @ 0x0`3 @ 0x1`4
	sub     {r1: register}, {r2: register}, {ro: register}    => ro`3 @ r2`3 @ r1`3 @ 0x1`3 @ 0x1`4
	mult    {r1: register}, {r2: register}, {ro: register}    => ro`3 @ r2`3 @ r1`3 @ 0x2`3 @ 0x1`4
	nand    {r1: register}, {r2: register}, {ro: register}    => ro`3 @ r2`3 @ r1`3 @ 0x3`3 @ 0x1`4

	addi    {ro: register}, {value: u8}                       => value`8 @ ro`3 @ 0x0`1 @ 0x2`4
	multi   {ro: register}, {value: u8}                       => value`8 @ ro`3 @ 0x1`1 @ 0x2`4

	shl     {r1: register}, {ro: register}                    => ro`3 @ 0x0`3 @ r1`3 @ 0x4`3 @ 0x1`4
	shr     {r1: register}, {ro: register}                    => ro`3 @ 0x0`3 @ r1`3 @ 0x5`3 @ 0x1`4

	jmp     {r1: register}                                    => 0x0`6 @ r1`3 @ 0x0`3 @ 0x4`4
	jmpz    {r1: register}                                    => 0x0`6 @ r1`3 @ 0x1`3 @ 0x4`4
	jmpg    {r1: register}                                    => 0x0`6 @ r1`3 @ 0x2`3 @ 0x4`4
	jmpe    {r1: register}                                    => 0x0`6 @ r1`3 @ 0x7`3 @ 0x4`4
	jmpl    {r1: register}                                    => 0x0`6 @ r1`3 @ 0x3`3 @ 0x4`4
	jmpm    {r1: register}                                    => 0x0`6 @ r1`3 @ 0x4`3 @ 0x4`4
	jmpu    {r1: register}                                    => 0x0`6 @ r1`3 @ 0x5`3 @ 0x4`4
	jmpi    {value: u16}                                      => 0x0`9 @ 0x6`3 @ 0x4`4 @ value`16  

	ld      {value: u16}, {ro: register}                      => ro`3 @ 0x0`6 @ 0x0`3 @ 0x5`4 @ value`16
	ldr     {r1: register}, {ro: register}                    => ro`3 @ 0x0`3 @ r1`3 @ 0x1`3 @ 0x5`4
	str     {r1: register}, {value: u16}                      => 0x0`3 @ r1`3 @ 0x0`3 @ 0x0`3 @ 0x6`4 @ value`16
	strr    {r2: register}, {r1: register}                    => 0x0`3 @ r2`3 @ r1`3 @ 0x1`3 @ 0x6`4

	ldi     {value: u9}, {ro: register}                       => value`9 @ ro`3 @ 0x7`4
	uart                                                      => 0x0`12 @ 0x8`4
}



