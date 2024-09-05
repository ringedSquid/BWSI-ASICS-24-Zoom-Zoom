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

#subruledef kregister
{
	k0 => 0x0
	k1 => 0x1
	k2 => 0x2
	k3 => 0x3
	k4 => 0x4
}

#subruledef kextend
{
	l => 0x0
	lm => 0x1
	um => 0x2
	u => 0x3
}

#ruledef 
{
	nop                                                  	  => 0x0`16

	add     {r1: register}, {r2: register}, {ro: register}    => ro`3 @ r2`3 @ r1`3 @ 0x0`3 @ 0x1`4
	sub     {r1: register}, {r2: register}, {ro: register}    => ro`3 @ r2`3 @ r1`3 @ 0x1`3 @ 0x1`4
	mult    {r1: register}, {r2: register}, {ro: register}    => ro`3 @ r2`3 @ r1`3 @ 0x2`3 @ 0x1`4
	nand    {r1: register}, {r2: register}, {ro: register}    => ro`3 @ r2`3 @ r1`3 @ 0x3`3 @ 0x1`4

	addi    {ro: register}, {value: u8}                       => value`8 @ ro`3 @ 0x0`1 @ 0x2`4
	multi   {ro: register}, {value: u8}                       => value`8 @ ro`3 @ 0x0`1 @ 0x2`4

	shl     {r1: register}, {ro: register}                    => ro`3 @ 0x0`3 @ r1`3 @ 0x4`3 @ 0x1`4
	shr     {r1: register}, {ro: register}                    => ro`3 @ 0x0`3 @ r1`3 @ 0x5`3 @ 0x1`4

	jmp     {r1: register}                                    => 0x0`6 @ r1`3 @ 0x0`3 @ 0x0`4
	jmpz    {r1: register}                                    => 0x0`6 @ r1`3 @ 0x1`3 @ 0x0`4
	jmpg    {r1: register}                                    => 0x0`6 @ r1`3 @ 0x2`3 @ 0x0`4
	jmpe    {r1: register}                                    => 0x0`6 @ r1`3 @ 0x7`3 @ 0x0`4
	jmpl    {r1: register}                                    => 0x0`6 @ r1`3 @ 0x3`3 @ 0x0`4
	jmpm    {r1: register}                                    => 0x0`6 @ r1`3 @ 0x4`3 @ 0x0`4
	jmpu    {r1: register}                                    => 0x0`6 @ r1`3 @ 0x5`3 @ 0x0`4
	jmpi    {value: u16}                                      => 0x0`9 @ 0x6`3 @ 0x4`4 @ value`16

	ld      {value: u16}, {ro: register}                      => ro`3 @ 0x0`6 @ 0x0`3 @ 0x5`4 @ value`16
	ldr     {r1: register}, {ro: register}                    => ro`3 @ 0x0`3 @ r1`3 @ 0x1`3 @ 0x5`4
	str     {r2: register}, {value: u16}                      => 0x0`3 @ r1`3 @ 0x0`3 @ 0x0`3 @ 0x6`4 @ value`16
	strr    {r2: register}, {r1: register}                    => 0x0`3 @ r2`3 @ r1`3 @ 0x1`3 @ 0x6`4

	ldi     {value: u9}, {ro: register}                       => value`9 @ ro`3 @ 0x7`4
	uart                                                      => 0x0`12 @ 0x8`4

	ldkrc		{kext1: kextend}, {k1: kregister}, {r1: register}	=> 0x0`2 @ kext1`2 @ k1`5 @ r1`3 @ 0x9`4
	uldkrc	{kext1: kextend}, {k1: kregister}, {r1: register} => 0x1`2 @ kext1`2 @ k1`5 @ r1`3 @ 0x9`4

	kxorinvand 																								=> 0x0`2 @ 0x0`10 @ 0x3`4
	ktheta																										=> 0x1`2 @ 0x0`10 @ 0x3`4
	krol 																											=> 0x2`2 @ 0x0`10 @ 0x3`4
	kxor 																											=> 0x3`2 @ 0x0`10 @ 0x3`4
}
