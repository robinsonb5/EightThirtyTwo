#include "assembler.pp"

	.section	.text.strcmp
	.global	_strcmp

_strcmp:						// Parameters: char *s1, char *s2
	stdec	r6
	li	4
	ldidx	r6
	mr	r1	// s1
	li	8
	ldidx	r6
	mr	r2	// s2
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
	ldinc	r6
	mr	r7



	.section	.text.strncmp
	.global	_strncmp
_strncmp:						// Parameters: char *s1, char *s2, int n
	stdec	r6
	mt	r3
	stdec	r3
	li	8
	ldidx	r6
	mr	r1
	li	12
	ldidx	r6
	mr	r2
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

