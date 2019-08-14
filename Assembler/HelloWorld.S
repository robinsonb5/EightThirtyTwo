#include	"assembler.pp"

start:
	li	IMW0(PCREL(message)-PCREL(start))
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
	li	IMW0(PCREL(_loop))
	add	r7

	ldbinc	r1
	cond	NEQ
	st	r0
	li	IMW0(PCREL(_loop))
	add	r7

	cond	NEX	// Terminate simulation

message:
	.ascii	"Hello, world!"
	.byte	0

