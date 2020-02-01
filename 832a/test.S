	.section .text.1
	.global	label2
	.global	label3
	.weak	label3
label1:
	li 0
	mr	r0
label2:
	li 3
	mr	r1
	and	r0
	.lipcrel	label1
label3:
	mul	r0
	.align 4
	.int 0x12344321
	.section .data
	.int	0x12345678
	.byte	0x10
	.align	4
	.byte	0x20
	.section .text.2
//	.int	0x12345678
	.comm	MyVar,4
	.align 8
	.lcomm	MyLocalHalfwordVar,2

	.section .text.3
	.comm	MyOtherVar,4
//	and r5

	.global	STACKTOP
	.abs	STACKTOP,0x2000

	.section .text.main
	.global	_main
_main:
	stdec	r6

	.lipcrel label3
	li	5
	mr	r0
	li	4
	add	r0

	ldinc	r6
	mr	r7

	.global init
init:
	stdec r6
	li	0
	mr	r0
	ldinc r6
	mr	r7

	.global cleanup
cleanup
	mr	r7

	.ctor .ctor.002
	.reloc _main

	.ctor .ctor.001
	.reloc init

	.dtor .dtor.001
	.reloc cleanup

