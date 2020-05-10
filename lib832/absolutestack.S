// Absolute stack pointer.  Can be included just by referencing the seed function _setstack

	.section .text.setstack
	.global	_setstack

	.constant _STACKTOP,8192
	.global _STACKTOP
	.weak	_STACKTOP

_setstack:
	mr	r7

__setstack:
	mr	r0
	.liabs	_STACKTOP
	exg	r6
	stdec	r6
	mt	r0
	mr	r7

__restorestack:
	mr	r0
	ldinc	r6
	mr	r6
	mt	r0
	mr	r7

	.ctor	.ctor.000
	.ref	__setstack

	.dtor	.dtor.000
	.ref	__restorestack

