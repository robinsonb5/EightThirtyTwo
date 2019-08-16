#include "assembler.pp"

start:
	li	IMW1(0x7fc)
	li	IMW0(0x7fc)
	mr	r6	// Set up the stack pointer

	li	IMW2(data-start)
	li	IMW1(data-start)
	li	IMW0(data-start)
	mr	r5	// r5 points to data
	li	2
	addt	r5
	exg	r5
	mr	r1	// r1 = r5+2

	li	IMW1(PCREL(loadhalfword-1))
	li	IMW0(PCREL(loadhalfword))
	addt	r7

	mt	r5
	mr	r1
	li	IMW1(PCREL(loadhalfword-1))
	li	IMW0(PCREL(loadhalfword))
	addt	r7	

	mt	r5
	mr	r1
	li	IMW2(0x55aa)
	li	IMW1(0x55aa)
	li	IMW0(0x55aa)
	mr	r0
	li	IMW1(PCREL(storehalfword-1))
	li	IMW0(PCREL(storehalfword))
	addt	r7

	li	6
	addt	r5
	exg	r5
	mr	r1	// r1=r5+6
	li	IMW2(0x55aa)
	li	IMW1(0x55aa)
	li	IMW0(0x55aa)
	mr	r0
	li	IMW0(PCREL(storehalfword))
	addt	r7

	ld	r5

	li	4	// Read 4 bytes beyond pointer
	addt	r5
	mr	r4	// old value of pointer is now in r4
	ld	r5

	ld	r4

	cond NEX	// Halt simuation


	// Read a halfword from address in r1, return in r0
loadhalfword:
	stdec	r6
	ld	r1
	mr	r0
	li	2
	and	r1
	cond	EQ	// upper word
	li	16
	lsr	r0
	ldinc	r6
	mr	r7
			// lower word
	li	IMW2(0xffff)
	li	IMW1(0xffff)
	li	IMW0(0xffff)
	and	r0
	ldinc	r6
	mr	r7

	// Write halfword in r0 to address in r1
storehalfword:
	stdec	r6
	li	8
	ror	r0
	mt	r0
	stbinc	r1
	li	24
	ror	r0
	mt	r0
	stbinc	r1
	ldinc	r6
	mr	r7

	.align 4
data:
	.byte 0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef

