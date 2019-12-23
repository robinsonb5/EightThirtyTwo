#include "assembler.pp"

	.section .text.startup

_start:
	cond	SGT	// Z flag and C flag both clear -> Thread 1
		li	IMW0(PCREL(.start1))
		add	r7

	cond	SLT	// Z flag clear, C flag set -> Thread 2
		li	IMW0(PCREL(.start2))
		add	r7

	// By elimination the Z flag must be set, so this must be an interrupt.
	// (The interrupt is triggered using the xor alu op, so C is not cleared.)

	exg	r6
	stdec	r0
	stdec	r6
	exg	r6

	ldinc	r7

	.global _InterruptVector	// This word can be written to install an int handler.  Location 11.
_InterruptVector:
	.int	_interrupt

	exg	r7

	ldinc	r6
	mr	r0
	li	IMW0(-1)
	add	r0		// Decrement return address
	ldinc r6
	exg	r0		// Restore r0
	mr	r7		// Jump to return address - 1.


.start1:
	// Set up the stack here
	ldinc	r7
	.int	_premain
	mr	r7
.start2:
	// Set up the stack here
	ldinc	r7
	.int	_premain2
	mr	r7

	.section	.text.premain
	.weak	_premain
	.globl _premain
_premain:
	// Setup the stack
#ifdef LDSTACK
	ldinc	r7
	.int	STACKTOP
	mr	r6
#else
	li	IMW2(0x2000)
	li	IMW1(0x2000)
	li	IMW0(0x2000)
	mr	r6
#endif

	// Clear BSS here
	ldinc	r7
	.int	_main
	exg	r7
.endloop:
	cond NEX	// Pause until an interrupt is received
	li	IMW0(PCREL(.endloop))
	add	r7

	.section	.text.premain2
	.weak	_premain2
_premain2:
#ifdef LDSTACK2
	ldinc	r7
	.int	STACKTOP2
	mr	r6
#else
	// Setup the stack
	li	IMW2(0x1c00)
	li	IMW1(0x1c00)
	li	IMW0(0x1c00)
	mr	r6
#endif

	// Clear BSS here
	ldinc	r7
	.int	_thread2main
	exg	r7
.endloop2:
	cond NEX	// Pause until an interrupt is received
	li	IMW0(PCREL(.endloop2))
	add	r7

	.weak	_thread2main
_thread2main:
	mr	r7	// Return immediately

	.section	.text.interrupt
	.weak	_interrupt
_interrupt:
	mr	r7	// return immediately

