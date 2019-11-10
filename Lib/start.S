#include "assembler.pp"

	.section	.text.premain
	.weak	.premain
_premain:
	// Setup the stack
	li	IMW2(0x800)
	li	IMW1(0x800)
	li	IMW0(0x800)
	mr	r6

	// Clear BSS here
	ldinc	r7
	.int	_main
	exg	r7
.endloop:
	li	IMW0(PCREL(.endloop))
	add	r7

	.section	.text.premain2
	.weak	.premain2
_premain2:
	// Setup the stack
	li	IMW2(0x400)
	li	IMW1(0x400)
	li	IMW0(0x400)
	mr	r6

	// Clear BSS here
	ldinc	r7
	.int	_thread2main
	exg	r7
.endloop2:
	li	IMW0(PCREL(.endloop2))
	add	r7

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
	cond	NEQ	// Thread 1
		li	IMW0(PCREL(.start1))
		add	r7
	cond	SLT	// Thread 2
		li	IMW0(PCREL(.start2))
		add	r7
	ldinc	r7
	.int	_interrupt	// Interrupt
	exg	r7

.start1:
	// Set up the stack here
	ldinc	r7
	.int	_premain
.start2:
	// Set up the stack here
	ldinc	r7
	.int	_premain2

