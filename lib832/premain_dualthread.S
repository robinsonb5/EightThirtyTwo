//
//  More comprehensive premain implementation.
//  The rudimentary premain in start.S has weak linkage, so this one will override it if linked.
//
//  Supports auto initialisation from .ctors section and clearing of BSS data.
//
//  STACKSIZE is defined to 1K, but is a weak symbol so can be overridden either in another section
//  or on the linker command line.

	.section	.text.premain
	.global	_premain
	.constant _STACKSIZE,4096
	.global _STACKSIZE
	.weak	_STACKSIZE
_premain:
	// Setup the stack
	.liabs	__bss_end__
	mr	r6
	.liabs	_STACKSIZE
	add	r6

	// Clear BSS data
	.liabs	__bss_end__
	mr	r1
	.liabs	__bss_start__
	mr	r0
	sub	r1
.clrwordloop
	li	16
	sub	r1
	cond	GE
		li	0
		stinc	r0
		stinc	r0
		stinc	r0
		stinc	r0
		.lipcrel	.clrwordloop
		add	r7

	li	16
	add	r1
	cond	NEQ
.clrbyteloop
		li	0
		stbinc	r0
		li	1
		sub	r1
		cond	NEQ	// Can nest conditions as long as they don't differ.
			.lipcrel .clrbyteloop
			add r7

	// Call constructors
	.liabs __ctors_end__
	mr	r4
	.liabs __ctors_start__
	mr	r5
.ctorloop:	// Call in reverse order
	mt	r4
	cmp	r5
	cond	EQ
		.lipcrel .ctordone
		add	r7

	li	4
	sub	r4
	ld	r4
	exg	r7

	.lipcrel .ctorloop
	add	r7

.ctordone:
	// Release the 2nd thread
	.liabs	releasethread2
	mr	r0
	li	1
	st	r0

	// FIXME - should push argc and argv on the stack before calling main.
	.lipcrel	_main
	add	r7

	// Call destructors
	ldinc	r7
	.ref	__dtors_start__
	mr	r4
	ldinc	r7
	.ref	__dtors_end__
	mr	r5
.dtorloop:
	mt	r4
	cmp	r5
	cond	EQ
		.lipcrel .endloop
		add	r7

	ldinc	r4
	exg	r7

	.lipcrel .dtorloop
	add	r7

.endloop:
	cond NEX	// Pause until an interrupt is received
	.lipcrel .endloop
	add	r7


	.section	.text.premain2
	.global releasethread2
releasethread2:
	.int	0
	.global	_premain2
_premain2:
	// Setup the stack
	.liabs	__bss_end__
	mr	r6
	.liabs	_STACKSIZE
	add	r6
	add r6	// 2nd thread's stack must be beyond the first one

	// wait for the first thread to finish clearing BSS.
	.liabs	releasethread2
	mr	r0
.waitrelease:
	ld	r0
	cond	EQ
		.lipcrel	.waitrelease
		add	r7

	// FIXME - should push argc and argv on the stack before calling main.
	.lipcrel	_thread2main
	add	r7

.endloop2:
	cond NEX	// Pause until an interrupt is received
	.lipcrel .endloop2
	add	r7

