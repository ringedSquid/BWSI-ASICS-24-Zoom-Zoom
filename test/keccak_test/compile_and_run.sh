#!/bin/bash

#delete files if they exist
if test -f program.bin; then
	rm program.bin
fi

if test -f program_checks.tv; then
	rm program_checks.tv
fi

#assemble program

customasm $1 -f annotatedbin -o program.bin
echo ""
echo "Annotated:"
cat program.bin
echo ""

customasm $1 -f hexstr -o program.bin
cp $2 program_checks.tv
echo ""
python3 splice.py

#compile and run verilog
iverilog x3q16_tb.v -I ../../src/
./a.out
