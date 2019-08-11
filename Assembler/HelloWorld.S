#include	"assembler.pp"

.org 0
start:
//	li	IMW1(PCREL(message+3))
	li	IMW0(PCREL(message+2))
	mr	r1
	li	IMW1(0xffffffc0)
	li	IMW0(0xffffffc0)
	mr	r0

_loop:
	li	IMW1(0x100)
	li	IMW0(0x100)
	mr	r2	// Flags
	ld	r0
	and	r2
	cond	EQ
	li	IMW0(-8)
	add	r7
	cond	EX

	ldbinc	r1
	cond	NEQ
	st	r0
	li	IMW0(-11)
	add	r7
	cond	EX
	cond	NEX

message:
	.ascii	"Hello, world!"
	.byte	0

