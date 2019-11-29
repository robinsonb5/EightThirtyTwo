#include "assembler.pp"

/* Integer division routines
   _div_u32byu32 - numerator in r1, denominator in r2,
   returns quotient in r0, remainder in r1.

   _div_s32bys32 just evaluates signs, negates and calls unsigned division.
   FIXME - check rounding and remainders for negative divisions.
*/

	.section .text._div_32by32
	.global	_div_u32byu32

_div_u32byu32:
	stdec	r6
	mt	r3	// Save r3
	stdec	r6

	mt	r2
	and	r2
	cond	EQ	// Division by zero?
		li	IMW0(PCREL(.end))
		add	r7

	li	0
	mr	r0
	li	1
	mr	r3

.start:
	mt	r2
	cmp	r1
	cond	SGT
		add	r2	// Faster than lsl
		mt	r3
		add	r3
		li IMW0(PCREL(.start))
		add	r7

.next:
	mt	r2
	cmp	r1
	cond	GE
		sub	r1
		mt	r3
		add	r0
		cond	EX

	li	1
	shr	r2
	shr	r3
	cond	NEQ
		li	IMW0(PCREL(.next))
		add	r7

.end:
	ldinc	r6
	mr	r3
	ldinc	r6
	mr	r7


	.global	_div_s32bys32

_div_s32bys32:
	stdec	r6
	mt	r5	// save r5.
	stdec	r6

	li	0
	mr	r5	// Keep track of signs here

	mt	r1	// Check sign of numerator.
	addt	r1
	cond	SLT	// Did we overflow?
		li	IMW0(-1)
		xor	r1	// Negate if negative
		li	IMW0(1)
		add	r1
		xor	r5	// and track the eventual sign bit
	cond EX

	mt	r2	// Check sign of denominator.
	addt	r2		
	cond	SLT
		li	IMW0(-1)
		xor	r2	// Negate if negative...
		li	IMW0(1)
		add	r2
		xor	r5	// If both numerator and denominator are negative then we don't need to negate the result.
	cond EX

	// Now perform an unsigned division.
	li	IMW0(PCREL(_div_u32byu32))
	add	r7
	mt	r5
	and	r5
	cond	NEQ	// Negate the result if necessary.
		li	IMW0(-1)
		xor	r0
		li	1
		add	IMW0(r0)
	cond EX

	// FIXME - what about the remainder?

	ldinc	r5
	mr	r5
	ldinc	r6
	mr	r7

