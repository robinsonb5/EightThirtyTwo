#include "assembler.pp"

// void *memset(__reg("r3") void *dst, __reg("r2") int c,__reg("r1") size_t size);

	.section	.text.lib
	.globl	_memset
_memset:
	stdec	r6
	mt	r3
	mr	r0
	add	r1
.loop:
	mt	r3
	cmp	r1
	cond	NEQ
		mt	r2
		stbinc	r3
		li	IMW0(PCREL(.loop))
		add	r7
.done:
	ldinc	r6
	mr	r7	// 13 bytes


