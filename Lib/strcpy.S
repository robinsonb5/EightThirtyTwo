#include "assembler.pp"

	// char *strncpy(__reg("r3") char *dst, __reg("r2") const char *src, __reg("r1") size_t size);

	.section	.text.lib
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

