#include "assembler.pp"


start:
	li	IMW1(PCREL(compressed)-PCREL(start))
	li	IMW0(PCREL(compressed)-PCREL(start))
	mr	r0
	mr	r1

	li	IMW2(0x1000)	// Stack pointer
	li	IMW1(0x1000)
	li	IMW0(0x1000)
	mr	r6

	li	IMW1(PCREL(decompressed)-PCREL(start))
	li	IMW0(PCREL(decompressed)-PCREL(start))
	mr	r1
	mr	r2

	li	IMW0(PCREL(lz4_depack))
	addt	r7
	cond NEX

//	r0 packed buffer
//	r1 destination pointer
//	r2 packed buffer end

lz4_depack:
	stdec	r6
	li	PCREL(.tokenLoop)
	add	r7
			
.lenOffset:
	ldbinc	r0
	mr	r3
	li	8
	ror	r3
	ldbinc	r0
	or	r3
	li	24
	ror	r3

	mt	r4
	mr	r5

	mt	r1
	mr	r4
	mt	r3
	sub	r4

	li	IMW1(PCREL(.readLen+1))
	li	IMW0(PCREL(.readLen))
	addt	r7

	li	4
	add	r5
.copy:
	ldbinc	r4
	stbinc	r1
	li	1
	sub	r5
	cond	NEQ
	li	IMW0(PCREL(.copy))
	add	r7
			
.tokenLoop:	
	ldbinc	r0
	mr	r4
	mr	r5
	li	15
	and	r4
	li	4
	lsr	r5
	cond	EQ
	li	IMW1(PCREL(.lenOffset+1))
	li	IMW0(PCREL(.lenOffset))
	add	r7

	li	IMW0(PCREL(.readLen))
	addt	r7

.litCopy:
	ldbinc	r0
	stbinc	r1
	li	1
	sub	r5
	cond	NEQ
	li	IMW0(PCREL(.litCopy))
	add	r7

	mt	r2
	cmp	r0
	cond	SGT
	li	IMW1(PCREL(.lenOffset+1))
	li	IMW0(PCREL(.lenOffset))
	add	r7
			
.over:
	ldinc	r6
	mr	r7

.readLen:
	stdec	r6
	li	15
	cmp	r5
	cond	NEQ
	li	IMW0(PCREL(.readEnd))
	add	r7

.readLoop:
	ldbinc	r0
	mr	r3
	add	r5
	li	IMW1(255)
	li	IMW0(255)
	xor	r3
	cond	EQ
	li	IMW0(PCREL(.readLoop))
	add	r7

.readEnd:
	ldinc	r6
	mr	r7

compressed:
.incbin "compressed.lz4"
decompressed:
	.fill	1024,1,-1

