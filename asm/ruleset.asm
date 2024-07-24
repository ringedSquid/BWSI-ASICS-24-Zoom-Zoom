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
	nop {r: register}, {src: source} => 0x0`16
	add {r1: register}, {r2: register}, {r3: register} => 0x1`4 @ 0x0`3 @ r1`3 @ r2`3 @ r3`3
	sub {r1: register}, {r2: register}, {r3: register} => 0x1`4 @ 0x1`3 @ r1`3 @ r2`3 @ r3`3
	mult {r1: register}, {r2: register}, {r3: register} => 0x1`4 @ 0x2`3 @ r1`3 @ r2`3 @ r3`3
	nand {r1: register}, {r2: register}, {r3: register} => 0x1`4 @ 0x3`3 @ r1`3 @ r2`3 @ r3`3
	addi {r1: register}, {value: u8} => 0x2`4 @ 0x0`1 @ r1`3 @ value`8
	multi {r1: register}, {value: u8} => 0x2`4 @ 0x0`1 @ r1`3 @ value`8



	

}
