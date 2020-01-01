#include "assembler.pp"


	// char *strncat(__reg("r2") char *, __reg("r1") const char *, __reg("r3") size_t);

	.section	.text.strncat
	.global	_strncat
_strncat:
	stdec	r6
.finddst:
	ldbinc	r2
	cond	NEQ
		li	IMW0(PCREL(.finddst))
		add	r7
	li	IMW0(1)
	sub	r2
.cpy:
	ldbinc	r1
	stbinc	r2
	cond	EQ	// Done?
		ldinc	r6
		mr	r7
	li	IMW0(1)
	sub	r3
	cond	NEQ
		li	IMW0(PCREL(.cpy))
		add	r7
	li	IMW0(0)
	stbinc	r2
	ldinc	r6
	mr	r7



	// char *strcat(__reg("r2") char *, __reg("r1") const char *);

	.section	.text.strcat
	.global	_strcat
_strcat:
	stdec	r6
.finddst2:
	ldbinc	r2
	cond	NEQ
		li	IMW0(PCREL(.finddst2))
		add	r7
	li	IMW0(1)
	sub	r2
.cpy2:
	ldbinc	r1
	stbinc	r2
	cond	NEQ
		li	IMW0(PCREL(.cpy2))
		add	r7
	ldinc	r6
	mr	r7



	// int strcmp(__reg("r2") const char *, __reg("r1") const char *);

	.section	.text.strcmp
	.global	_strcmp

_strcmp:						// Parameters: char *s1, char *s2
	stdec	r6
	mt	r2
	stdec	r6
.loopstrcmp:
	ldbinc	r2	// s2++
	mr	r0
	ldbinc	r1
	cond	EQ					// If null, we're done.  If S2 has also terminated, r0 will be 0; else a positive number.
		li	IMW0(PCREL(.end))
		add	r7
	sub	r0						// Otherwise subtract 
	cond	EQ
		li	IMW0(PCREL(.loopstrcmp))
		add	r7
.end:
	ldinc	r6
	mr	r2
	ldinc	r6
	mr	r7



// int strncmp(__reg("r2") const char *, __reg("r1") const char *, __reg("r3") size_t);

	.section	.text.strncmp
	.global	_strncmp
_strncmp:						// Parameters: char *s1, char *s2, int n
	stdec	r6
	mt	r3
	stdec	r6
	mt	r2
	stdec	r6
.loopstrncmp:
	li	1
	sub	r3
	cond SLT
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
	mr	r2
	ldinc	r6
	mr	r3
	ldinc	r6
	mr	r7



// int memcmp(__reg("r2") const char *, __reg("r1") const char *, __reg("r3") size_t);

	.section	.text.memcmp
	.global	_memcmp
_memcmp:						// Parameters: char *s1, char *s2, int n
	stdec	r6
	mt	r3
	stdec	r6
	mt	r2
	stdec	r6
.loopmemcmp:
	li	1
	sub	r3
	cond SLT
		li	IMW0(PCREL(.endstrncmp))
		add	r7
	ldbinc	r2	// s2++
	mr	r0
	ldbinc	r1
	sub	r0						// Perform comparison
	cond	EQ
		li	IMW0(PCREL(.loopmemcmp))
		add	r7
.endmemcmp:
	ldinc	r6
	mr	r2
	ldinc	r6
	mr	r3
	ldinc	r6
	mr	r7



	// char *strncpy(__reg("r3") char *dst, __reg("r2") const char *src, __reg("r1") size_t size);

	.section	.text.strncpy
	.globl	_strncpy
_strncpy:
	stdec	r6
	mt	r3
	mr	r0
	add	r1
.strnloop:
	mt	r3
	cmp	r1
	cond	EQ
		li	IMW0(PCREL(.done))
		add	r7
	ldbinc r2
	stbinc	r3
	cond	NEQ
		li	IMW0(PCREL(.strnloop))
		add	r7
.done:
	ldinc	r6
	mr	r7	// 16 bytes



	// char *strcpy(__reg("r2") char *dst, __reg("r1") const char *src);

	.section	.text.strcpy
	.globl	_strcpy
_strcpy:
	stdec	r6
	mt	r2
	mr	r0
.strcpyloop:
	ldbinc r1
	stbinc	r2
	cond	NEQ
		li	IMW0(PCREL(.strcpyloop))
		add	r7
	ldinc	r6
	mr	r7	// 10 bytes



	// size_t strlen(__reg("r1" const char *);

	.section	.text.strlen
	.global	_strlen
_strlen:
	stdec	r6

	mt	r1
	mr	r0
	ldbinc	r1
.loopstrlen:
	ldbinc	r0
	cond	EQ
		mt	r1
		sub	r0
		ldinc	r6
		mr	r7
	li	IMW0(PCREL(.loopstrlen))
	add	r7	// 12 bytes



	// int tolower(__reg("r1") int c);

	.section	.text.tolower
	.global	_tolower
_tolower:
	stdec	r6

	mt	r1
	mr	r0

	li	IMW1('A')
	li	IMW0('A')
	sub	r1
	cond	SLT
		ldinc	r6
		mr	r7
	li	IMW0(26)
	cmp	r1
	cond	SLT
		li	IMW1(32)
		li	IMW0(32)
		or	r0
		cond EX
	ldinc	r6
	mr	r7



	// int toupper(__reg("r1") int c);

	.section	.text.toupper
	.global	_toupper
_toupper:
	stdec	r6

	mt	r1
	mr	r0

	li	IMW1('a')
	li	IMW0('a')
	sub	r1
	cond	SLT
		ldinc	r6
		mr	r7
	li	IMW0(26)
	cmp	r1
	cond	SLT
		li	IMW1(~32)
		li	IMW0(~32)
		and	r0
		cond EX
	ldinc	r6
	mr	r7



	// void *memset(__reg("r3") void *dst, __reg("r2") int c,__reg("r1") size_t size);

	.section	.text.memset
	.globl	_memset
_memset:
	stdec	r6
	mt	r3
	mr	r0
	add	r1
.loopmemset:
	mt	r3
	cmp	r1
	cond	NEQ
		mt	r2
		stbinc	r3
		li	IMW0(PCREL(.loopmemset))
		add	r7
	ldinc	r6
	mr	r7	// 13 bytes


