/*
  More comprehensive premain implementation.
  The rudimentary premain in start.S has weak linkage, so this one will override it if linked.

  Supports auto initialisation from .ctors section and clearing of BSS data.

*/

#include "assembler.pp"

	.section	.text.premain
	.global	_premain
_premain:
	// Setup the stack
	ldinc	r7
	.int	STACKTOP
	mr	r6

	// Clear BSS data
	ldinc	r7
	.int	__bss_end__
	mr	r1
	ldinc	r7
	.int	__bss_start__
	mr	r0
.clrloop:
	mt	r0
	cmp	r1
	cond	NEQ
		li	0
		stbinc	r0	// FIXME - faster to clear by word, but need to clear any remainder bytewise.
		li	IMW0(PCREL(.clrloop))
		add	r7

	// Call constructors
	ldinc	r7
	.int	__ctors_end__
	mr	r4
	ldinc	r7
	.int	__ctors_start__
	mr	r5
.ctorloop:	// Call in reverse order
	mt	r4
	cmp	r5
	cond	EQ
		li IMW0(PCREL(.ctordone))
		add	r7

	li	4
	sub	r4
	ld	r4
	exg	r7

	li IMW0(PCREL(.ctorloop))
	add	r7

.ctordone:
	// FIXME - should push argc and argv on the stack before calling main.
	ldinc	r7
	.int	_main
	exg	r7

	// Call destructors
	ldinc	r7
	.int	__dtors_start__
	mr	r4
	ldinc	r7
	.int	__dtors_end__
	mr	r5
.dtorloop:
	mt	r4
	cmp	r5
	cond	EQ
		li IMW0(PCREL(.endloop))
		add	r7

	ldinc	r4
	exg	r7

	li IMW0(PCREL(.dtorloop))
	add	r7

.endloop:
	cond NEX	// Pause until an interrupt is received
	li	IMW0(PCREL(.endloop))
	add	r7

