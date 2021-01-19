	.section .text.threads

_thread_sleepflag:
	.int	0

// Thread_asleep can be used to tell whether or not the other thread has finished.
// Due to concurrency issues the answer is not definitive if negative, since the 
// thread could have completed and slept since the test was made - but it should
// be definitive when positive.

	.global _thread_asleep:
_thread_asleep:
	mr	r0
	.lipcrel _thread_sleepflag
	addt	r7
	ldt
	exg	r0
	mr	r7

// Put the thread to sleep, marking a flag in the process.
// Note, this code has no concept of which thread is sleeping, so you should
// always designate one thread as subservient to the other.

	.global _thread_sleep
_thread_sleep:
	mr	r0
	li	1
	mr	r1
	.lipcrel _thread_sleepflag,4
	addt	r7
	stmpdec	r1
	sig		// Wake up the other thread if it's sleeping, to insure against deadlocks.
	cond NEX
	mt	r0	// Nop, first instruction after sleep is lost
	mt	r0
	mr	r7

// Unpausing the other thread is as simple as issuing a sig instruction
// Provided you've previously waited 
	.global	_thread_wake
_thread_wake:
	stdec	r6
	.lipcrel	_thread_asleep
	add	r7
	mr	r0
	and	r0
	cond	NEQ	// Is the other thread asleep?
		li	0	// If so, clear the sleep thread before waking it
		mr	r0
		.lipcrel _thread_sleepflag,4
		addt	r7
		stmpdec,r0
		cond EX
	sig
	ldinc	r6
	mr	r7

