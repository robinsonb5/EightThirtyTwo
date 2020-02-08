	.section	.text
	.global	_main
_main:
	stdec	r6

	.liabs	l2
	stdec	r6

	.lipcrel _puts
	add	r7

	li	4
	add	r6

	li	0
	mr	r0
	ldinc	r6
	mr	r7

	.section	.rodata
l2:
	.byte	72
	.byte	101
	.byte	108
	.byte	108
	.byte	111
	.byte	32
	.byte	119
	.byte	111
	.byte	114
	.byte	108
	.byte	100
	.byte	33
	.byte	10
	.byte	0
