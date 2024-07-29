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
	nop 	 						=> 0x0`16
	add 	{r1: register}, {r2: register}, {ro: register} 	=> 0x1`4 @ 0x0`3 @ r1`3  @ r2`3 	@ ro`3
	sub 	{r1: register}, {r2: register}, {ro: register} 	=> 0x1`4 @ 0x1`3 @ r1`3  @ r2`3 	@ ro`3
	mult 	{r1: register}, {r2: register}, {ro: register} 	=> 0x1`4 @ 0x2`3 @ r1`3  @ r2`3 	@ ro`3
	nand 	{r1: register}, {r2: register}, {ro: register} 	=> 0x1`4 @ 0x3`3 @ r1`3  @ r2`3 	@ ro`3
	addi 	{ro: register}, {value: u8} 			=> 0x2`4 @ 0x0`1 @ ro`3  @ value`8
	multi 	{ro: register}, {value: u8} 			=> 0x2`4 @ 0x0`1 @ ro`3  @ value`8
	shl	{r1: register}, {ro: register} 			=> 0x1`4 @ 0x4`3 @ r1`3  @ 0x0`3 	@ ro`3
	shr	{r1: register}, {ro: register} 			=> 0x1`4 @ 0x5`3 @ r1`3  @ 0x0`3 	@ ro`3
	jmp 	{r1: register}					=> 0x4`4 @ 0x0`3 @ r1`3  @ 0x0`6
	jmpz	{r1: register}					=> 0x4`4 @ 0x1`3 @ r1`3  @ 0x0`6
	jmpg	{r1: register}					=> 0x4`4 @ 0x2`3 @ r1`3  @ 0x0`6
	jmpe	{r1: register}					=> 0x4`4 @ 0x7`3 @ r1`3  @ 0x0`6
	jmpl	{r1: register}					=> 0x4`4 @ 0x3`3 @ r1`3  @ 0x0`6
	jmpm	{r1: register}					=> 0x4`4 @ 0x4`3 @ r1`3  @ 0x0`6
	jmpu	{r1: register}					=> 0x4`4 @ 0x5`3 @ r1`3  @ 0x0`6
	jmpi	{value: u16}					=> 0x4`4 @ 0x6`3 @ 0x0`9 @ value`16
	ld	{value: u16}, 	{ro: register}			=> 0x5`4 @ 0x0`3 @ 0x0`6 @ ro`3 	@ value`16 
	ldr	{r1: register}, {ro: register}			=> 0x5`4 @ 0x1`3 @ r1`3  @ 0x0`3 	@ ro`3
	str	{r2: register}, {value: u16}			=> 0x6`4 @ 0x0`3 @ 0x0`3 @ r1`3 	@ 0x0`3 	@ value`16
	strr 	{r2: register}, {r1: register}			=> 0x6`4 @ 0x1`3 @ r1`3  @ r2`3 	@ 0x0`3
	ldi	{value: u9},	{ro: register}			=> 0x7`4 @ ro`3	 @ value`9
	uart							=> 0x8`4 @ 0x0`12
}
