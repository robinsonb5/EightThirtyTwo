#include "assembler.pp"
	.xdef	_main
	.xdef	_thread2main
_main:
	stdec	r6
	li	0
	mr	r0
	li	IMW1(0xFFFFFFC0)
	li	IMW0(0xFFFFFFC0)
	mr	r1
	li	IMW1(0x48)
	li	IMW0(0x48)
	st	r1
	ldinc	r6
	mr	r7

_thread2main:
	stdec	r6
	li	1
	mr	r1
	li	IMW1(0xFFFFFFC0)
	li	IMW0(0xFFFFFFC0)
	mr	r2
	li	IMW1(0x60)
	li	IMW0(0x60)
	st	r2
	ldinc	r6
	mr	r7


	
