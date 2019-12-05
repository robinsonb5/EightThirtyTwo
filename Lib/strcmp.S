#include "assembler.pp"

	.section	.text.strcmp
	.global	_strcmp

#if 0
// "Cheat" version of _strcmp that compares using words as far as possible,
// then recompares the last word in bytes.  Not valid without checking for null terminations on a bytewise basis,
// Might be more useful in strncmp format.

_strcmp:
	exg	r6
	mr	r0
	stmpdec	r6
	stmpdec	r2
	exg	r6
	ldinc	r0
	mr	r2
	ldinc	r0
	mr	r1
.wordloop:
	ldinc	r2
	mr	r0
	ldinc	r1
	sub	r0
	cond	EQ
		li IMW0(PCREL(.wordloop))
		add	r7
	li	4
	sub	r1
	sub	r2
.byteloop:
	ldbinc	r2	// s2++
	mr	r0
	ldbinc	r1
	cond	EQ					// If null, we're done.  If S2 has also terminated, r0 will be 0; else a positive number.
		li	IMW0(PCREL(.strcmpend))
		add	r7
	sub	r0						// Otherwise subtract 
	cond	EQ
		li	IMW0(PCREL(.byteloop))
		add	r7
.strcmpend:
	ldinc	r6
	mr	r2
	ldinc	r6
	mr	r7
#endif
	
	
	// FIXME - need to save r2
_strcmp:						// Parameters: char *s1, char *s2
	stdec	r6
//	mt	r2
//	stdec	r6
//	li	8
//	ldidx	r6
//	mr	r2	// s1
//	li	12
//	ldidx	r6
//	mr	r1	// s2
.loop:
	ldbinc	r2	// s2++
	mr	r0
	ldbinc	r1
	cond	EQ					// If null, we're done.  If S2 has also terminated, r0 will be 0; else a positive number.
		li	IMW0(PCREL(.end))
		add	r7
	sub	r0						// Otherwise subtract 
	cond	EQ
		li	IMW0(PCREL(.loop))
		add	r7
.end:
//	ldinc	r6
//	mr	r2
	ldinc	r6
	mr	r7



	.section	.text.strncmp
	.global	_strncmp
_strncmp:						// Parameters: char *s1, char *s2, int n
	stdec	r6
	mt	r3
	stdec	r6
	li	8
	ldidx	r6
	mr	r2
	li	12
	ldidx	r6
	mr	r1
	li	16
	ldidx	r6
	mr	r3
.loopstrncmp:
	li	1
	sub	r3
	cond SLT
		li	0
		li	IMW0(PCREL(.endstrncmp))
		add	r7
	ldbinc	r2	// s2++
	mr	r0
	ldbinc	r1
	cond	EQ					// If null, we're done.  If S2 has also terminated, r0 will be 0; else a positive number.
		li	IMW0(PCREL(.endstrncmp))
		add	r7
	sub	r0						// Otherwise subtract 
	cond	EQ
		li	IMW0(PCREL(.loopstrncmp))
		add	r7
.endstrncmp:
	ldinc	r6
	mr	r3
	ldinc	r6
	mr	r7

