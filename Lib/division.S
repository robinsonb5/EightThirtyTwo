#include "assembler.pp"

/* Integer division routines
   _div_u32byu32 - numerator in r1, denominator in r2,
   returns quotient in r0, remainder in r1.

   _div_s32bys32 just evaluates signs, negates and calls unsigned division.
   FIXME - check rounding and remainders for negative divisions.
*/

	.section .text._div_32by32
	.global	_div_u32byu32

// Updated division algorithm.  Old one was prone to failure if the numerator was large enough
// that there was no headroom for shifting the denominator until it was larger.
// This one's significantly slower.
#if 0

_div_u32byu32:
	stdec	r6
	mt	r3
	stdec	r6
	mt	r4
	stdec	r6

	li	IMW0(-1)
	xor	r2

	// R := 0
	li	1	// Anticipate the first 1 after the first loop.
	mr	r3	// R

	//if D = 0 then error(DivisionByZeroException) end
	add	r2
	cond EQ	// Division by zero?  FIXME - should be an error.
		li	IMW1(PCREL(.end)-1)
		li	IMW0(PCREL(.end))
		add	r7

	li	IMW1(32)
	li	IMW0(32)
	mr	r4

	//	Q := 0                  -- Initialize quotient and remainder to zero
	li	0
	mr	r0	// Q	

	// Initial loop - no point in manipulating R and Q until we've encountered at least 1 set bit.
.initloop:
	mt	r1
	sgn
	add	r1	// Shift left 1 place

	cond	SGT	// Was N's MSB set?
		li	1
		sub	r4
		li	IMW0(PCREL(.initloop))
		add	r7

	li	1
	or	r1	// Prevent zero causing trouble later.

	li	IMW1(PCREL(.entry)-1)
	li	IMW0(PCREL(.entry))
	add	r7

.divloop:

	mt	r1
	sgn
	add	r1
	li	0
	cond	SLT	// Was N's MSB set?
		li	1
		cond	EX

	addt	r3
	add	r3	// R = R<<1 | N(msb)

	mt	r0
	add	r0	// Q <<= 1

	// D has been negated, so adding it computes R-D
	mt	r2
	sgn
	addt	r3
	cond	GE	// R>=D?
		mr	r3
		li	1
		or	r0	 // Q |= 1
		cond	EX

.entry:
	li	1
	sub	r4
	cond NEQ
		li	IMW1(PCREL(.divloop)-1)
		li	IMW0(PCREL(.divloop))
		add	r7

	mt	r3
	mr	r1

.end:
	ldinc	r6
	mr	r4
	ldinc	r6
	mr	r3
	ldinc	r6
	mr	r7
#endif

#if 1

_div_u32byu32:
	stdec	r6
	mt	r3	// Save r3
	stdec	r6

	mt	r2
	and	r2
	cond	EQ	// Division by zero?
		li	IMW1(PCREL(.end)-1)
		li	IMW0(PCREL(.end))
		add	r7

	li	0
	mr	r0
	li	1
	mr	r3

	mt	r2
	cmp	r1
	cond	LE
		li	IMW1(PCREL(.next)-1)
		li	IMW0(PCREL(.next))
		add	r7

.start:
	mt	r3	// We adjust the marker first so that we can detect overflow.
	add	r3
	cond	EQ	// Did we just shift the marker bit off the left hand end?
		li	1	// If so, replace it on the extreme right, to be put back by a subsequent ror.
		mr	r3
		li	IMW0(PCREL(.aligned))
		add	r7

	mt	r2
	cmp	r1
	cond	SGT
		add	r2	// Faster than lsl
		li IMW0(PCREL(.start))
		add	r7

.aligned:
	li	1
	ror	r3

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
#endif

	.global	_div_s32bys32

_div_s32bys32:
	stdec	r6
	mt	r5	// save r5.
	stdec	r6

	li	0
	mr	r5	// Keep track of signs here

	mt	r1	// Check sign of numerator.
	addt	r1
	cond	LE	// Did we overflow?
		li	IMW0(-1)
		xor	r1	// Negate if negative
		li	IMW0(1)
		add	r1
		xor	r5	// and track the eventual sign bit
	cond EX

	mt	r2	// Check sign of denominator.
	addt	r2
	cond	LE
		li	IMW0(-1)
		xor	r2	// Negate if negative...
		li	IMW0(1)
		add	r2
		xor	r5	// If both numerator and denominator are negative then we don't need to negate the result.
	cond EX

	// Now perform an unsigned division.
	li	IMW1(PCREL(_div_u32byu32)-1)
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

	ldinc	r6
	mr	r5
	ldinc	r6
	mr	r7

