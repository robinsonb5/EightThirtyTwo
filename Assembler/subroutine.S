#include	"assembler.pp"

.org 0
start:
	li	IMW1(0x400)
	li	IMW0(0x400)
	mr	r6	// Setup the stack pointer
	li	0
	mr	r0
	li	PCREL(Subroutine)
	add	r7
	cond	NEX

Subroutine:
	stdec	r6
	li	5
	add	r0
	ldinc	r6
	mr	r7

