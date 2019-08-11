#include	"assembler.pp"

start:
	li	IMW1(0x40)
	li	IMW0(0x40)
	mr	r1
	li	IMW1(0xffffffc0)
	li	IMW0(0xffffffc0)
	mr	r0
	li	IMW1(0x100)
	li	IMW0(0x100)
	mr	r2	// Flags

_loop:
	ld	r0
	and	r2
	cond	EQ
	li	IMW0(-4)
	add	r7
	cond	EX

	ldbinc	r1
	cond	NEQ
	st	r0
	li	IMW0(-10)
	add	r7
	cond	EX
	cond	NEX

.org	0x40
message:
	.ascii	"Hello,	world"
	.byte	0

