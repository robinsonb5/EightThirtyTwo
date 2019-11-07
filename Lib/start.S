#include "assembler.pp"

	.section	.text.premain
	.weak	.premain
_premain:
	// Setup the stack

	// Clear BSS here
	ldinc	r7
	.int	_main
	exg	r7

	.section	.text.interrupt
	.weak	.interrupt
_interrupt:
	exg	r6
	stdec	r0
	stdec	r6
	exg	r6

	// Service interrupt here.

	ldinc	r6
	mr	r0
	li	IMW0(-1)
	add	r0		// Decrement return address
	ldinc r6
	exg	r0		// Restore r0
	mr	r7		// Jump to return address - 1.

	.section .text.startup

_start:
	cond	NEQ
		li	IMW0(PCREL(.start2))
		add	r7
	ldinc	r7
	.int	_interrupt
	exg	r7

.start2:
	// Set up the stack here
	ldinc	r7
	.int	_premain
	exg	r7
.end
	li	IMW0(PCREL(.end))
	mr	r7

