#include "assembler.pp"

	//registers used:
		//r0: yes
		//r1: yes
		//r2: yes
		//r3: yes
		//r4: yes
		//r5: no
		//r6: yes
		//r7: yes
		//tmp: yes
	.section	.text.0
	.global	__readMilliseconds
__readMilliseconds:
	exg	r6
	stmpdec	r6
	stmpdec	r2
	stmpdec	r3
	stmpdec	r4
	exg	r6
				// allocreg r3

	//dhry_1.c, line 79
					// (a/p assign)
					// (prepobj r1) reg r3 - no need to prep
					// (load_temp - type 3) not varadr
					// (objtotemp) const/deref # FIXME deal with different data sizes when dereferencing
					// (prepobj r0) const/deref
				// constant: ffffffc8 in 2 chunks
	li	IMW1(-56)
	li	IMW0(-56)
	mr	r0
	ld	r0
					// (save temp) isreg
	mr	r3
				//save_temp done
				// allocreg r2

	//dhry_1.c, line 80
					// (bitwise) loadreg
					// (objtotemp) reg r3
	mt	r3
	mr	r2
					// (objtotemp) const
				// constant: 18 in 1 chunks
	li	IMW0(24)
	sgn
	shr	r2
					// (save result) isreg

	//dhry_1.c, line 80
					// (bitwise) loadreg
					// (objtotemp) const
				// constant: ff in 2 chunks
	li	IMW1(255)
	li	IMW0(255)
	and	r2
					// (save result) isreg
				// allocreg r4

	//dhry_1.c, line 81
					// (bitwise) loadreg
					// (objtotemp) reg r3
	mt	r3
	mr	r4
					// (objtotemp) const
				// constant: 8 in 1 chunks
	li	IMW0(8)
	sgn
	shr	r4
					// (save result) isreg

	//dhry_1.c, line 81
					// (bitwise) loadreg
					// (objtotemp) const
				// constant: ff00 in 3 chunks
	li	IMW2(65280)
	li	IMW1(65280)
	li	IMW0(65280)
	and	r4
					// (save result) isreg

	//dhry_1.c, line 81
					// (bitwise) loadreg
					// (objtotemp) reg r2
	mt	r2
	mr	r2
					// (objtotemp) reg r4
	mt	r4
	or	r2
					// (save result) isreg
				// freereg r4
				// allocreg r4

	//dhry_1.c, line 82
					// (bitwise) loadreg
					// (objtotemp) reg r3
	mt	r3
	mr	r4
					// (objtotemp) const
				// constant: 8 in 1 chunks
	li	IMW0(8)
	shl	r4
					// (save result) isreg

	//dhry_1.c, line 82
					// (bitwise) loadreg
					// (objtotemp) const
				// constant: ff0000 in 5 chunks
	li	IMW4(16711680)
	li	IMW3(16711680)
	li	IMW2(16711680)
	li	IMW1(16711680)
	li	IMW0(16711680)
	and	r4
					// (save result) isreg

	//dhry_1.c, line 82
					// (bitwise) loadreg
					// (objtotemp) reg r2
	mt	r2
	mr	r2
					// (objtotemp) reg r4
	mt	r4
	or	r2
					// (save result) isreg
				// freereg r4

	//dhry_1.c, line 83
					// (bitwise) loadreg
					// (objtotemp) const
				// constant: 18 in 1 chunks
	li	IMW0(24)
	shl	r3
					// (save result) isreg

	//dhry_1.c, line 83
					// (bitwise) loadreg
					// (objtotemp) const
				// constant: ff00000 in 5 chunks
	li	IMW4(267386880)
	li	IMW3(267386880)
	li	IMW2(267386880)
	li	IMW1(267386880)
	li	IMW0(267386880)
	and	r3
					// (save result) isreg

	//dhry_1.c, line 83
					// (bitwise) loadreg
					// (objtotemp) reg r2
	mt	r2
	mr	r2
					// (objtotemp) reg r3
	mt	r3
	or	r2
					// (save result) isreg
				// freereg r3

	//dhry_1.c, line 84
					//setreturn
					// (load_temp - type 4) not varadr
					// (objtotemp) reg r2
	mt	r2
	mr	r0
				// freereg r2
	ldinc	r6
	mr	r4
	ldinc	r6
	mr	r3
	ldinc	r6
	mr	r2
	ldinc	r6
	mr	r7

// stacksize=0+??
	//registers used:
		//r0: yes
		//r1: yes
		//r2: yes
		//r3: yes
		//r4: yes
		//r5: yes
		//r6: yes
		//r7: yes
		//tmp: yes
	.section	.text.0
	.global	_main
_main:
	exg	r6
	stmpdec	r6
	stmpdec	r2
	stmpdec	r3
	stmpdec	r4
	stmpdec	r5
	exg	r6
				// constant: 10 in 1 chunks
	li	IMW0(16)
	sub	r6
				// allocreg r5
				// allocreg r4
					// (a/p assign)
					// (prepobj r1) reg r4 - no need to prep
					// (load_temp - type 3) not varadr
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
				// constant: 4 in 1 chunks
	li	IMW0(4)
	ldidx	r6
					// (save temp) isreg
	mr	r4
				//save_temp done
				// allocreg r2

	//dhry_1.c, line 125
					// (a/p assign)
					// (prepobj r1) extern (offset 0)
	ldinc	r7
	.int	_Next_Ptr_Glob
	mr	r1
					// (load_temp - type 10)					// (prepobj tmp) extern (offset 0)
	ldinc	r7
	.int	_rec1
					// (save temp) store prepped reg
	st	r1
				//save_temp done

	//dhry_1.c, line 126
					// (a/p assign)
					// (prepobj r1) extern (offset 0)
	ldinc	r7
	.int	_Ptr_Glob
	mr	r1
					// (load_temp - type 10)					// (prepobj tmp) extern (offset 0)
	ldinc	r7
	.int	_rec2
					// (save temp) store prepped reg
	st	r1
				//save_temp done

	//dhry_1.c, line 128
					// (a/p assign)
					// (prepobj r1) extern (offset 0)
	ldinc	r7
	.int	_rec2
	mr	r1
					// (load_temp - type 10)					// (prepobj tmp) extern (offset 0)
	ldinc	r7
	.int	_rec1
					// (save temp) store prepped reg
	st	r1
				//save_temp done

	//dhry_1.c, line 129
					// (a/p assign)
					// (prepobj r1) extern (offset 4)
	ldinc	r7
	.int	_rec2 + 4
	mr	r1
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 0 in 1 chunks
	li	IMW0(0)
					// (save temp) store prepped reg
	st	r1
				//save_temp done

	//dhry_1.c, line 130
					// (a/p assign)
					// (prepobj r1) extern (offset 8)
	ldinc	r7
	.int	_rec2 + 8
	mr	r1
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 2 in 1 chunks
	li	IMW0(2)
					// (save temp) store prepped reg
	st	r1
				//save_temp done

	//dhry_1.c, line 131
					// (a/p assign)
					// (prepobj r1) extern (offset 12)
	ldinc	r7
	.int	_rec2 + 12
	mr	r1
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 28 in 2 chunks
	li	IMW1(40)
	li	IMW0(40)
					// (save temp) store prepped reg
	st	r1
				//save_temp done

	//dhry_1.c, line 133
					// (a/p assign)
					// (prepobj r1) extern (offset 16)
	ldinc	r7
	.int	_rec2 + 16
	mr	r1
// (char with size!=1 -> array of unknown type)
// Copying 31 bytes to rec2
					// (load_temp - type 1) not varadr
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l3
	mr	r0
	mt	r2
	stdec	r6
				// constant: 1f in 1 chunks
	li	IMW0(31)
	addt	r1
	mr	r2
.cpyrec2loop0:
	ldbinc	r0
	stbinc	r1
	mt	r1
	cmp	r2
	cond	NEQ
		li	IMW0(PCREL(.cpyrec2loop0))
		add	r7
	ldinc	r6
	mr	r2

	//dhry_1.c, line 134
					// (a/p assign)
					// (prepobj r1) extern (offset 0)
	ldinc	r7
	.int	_Str_1_Loc
	mr	r1
// (char with size!=1 -> array of unknown type)
// Copying 31 bytes to Str_1_Loc
					// (load_temp - type 1) not varadr
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l4
	mr	r0
	mt	r2
	stdec	r6
				// constant: 1f in 1 chunks
	li	IMW0(31)
	addt	r1
	mr	r2
.cpyStr_1_Locloop1:
	ldbinc	r0
	stbinc	r1
	mt	r1
	cmp	r2
	cond	NEQ
		li	IMW0(PCREL(.cpyStr_1_Locloop1))
		add	r7
	ldinc	r6
	mr	r2

	//dhry_1.c, line 136
					// (a/p assign)
					// (prepobj r1) extern (offset 1628)
	ldinc	r7
	.int	_Arr_2_Glob + 1628
	mr	r1
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: a in 1 chunks
	li	IMW0(10)
					// (save temp) store prepped reg
	st	r1
				//save_temp done

	//dhry_1.c, line 141
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l5
	stdec	r6

	//dhry_1.c, line 141
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 142
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l6
	stdec	r6

	//dhry_1.c, line 142
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 143
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l7
	stdec	r6

	//dhry_1.c, line 143
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 144
					// (test)
					// (objtotemp) extern
	ldinc	r7
	.int	_Reg
	ldt//marker 3

	//dhry_1.c, line 144
	cond	EQ
					//conditional branch 			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l9)-1)
	li	IMW0(PCREL(l9))
		add	r7

	//dhry_1.c, line 146
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l10
	stdec	r6

	//dhry_1.c, line 146
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 147
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l11
	stdec	r6

	//dhry_1.c, line 147
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 150
			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l12)-1)
	li	IMW0(PCREL(l12))
	add	r7
l9: # 

	//dhry_1.c, line 151
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l13
	stdec	r6

	//dhry_1.c, line 151
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 152
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l14
	stdec	r6

	//dhry_1.c, line 152
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6

l12: # 

	//dhry_1.c, line 156
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Number_Of_Runs
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 156
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l15
	stdec	r6

	//dhry_1.c, line 156
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 171
					//call
	ldinc	r7
	.int	__readMilliseconds
	exg	r7
				// constant: 0 in 1 chunks
	li	IMW0(0)
	add	r6


	//dhry_1.c, line 171
					// (getreturn)					// (save result) store reg
// Store_reg to type 0x4
					// (prepobj tmp) extern (offset 0)
	ldinc	r7
	.int	_Begin_Time
	stmpdec	r0

	//dhry_1.c, line 173
					// (a/p assign)
					// (prepobj r1) reg r5 - no need to prep
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 1 in 1 chunks
	li	IMW0(1)
					// (save temp) isreg
	mr	r5
				//save_temp done

	//dhry_1.c, line 174
					// (compare) (q1 signed) (q2 signed)					// (objtotemp) extern
	ldinc	r7
	.int	_Number_Of_Runs
	ldt//marker 3
	mr	r1
					// (objtotemp) const
				// constant: 0 in 1 chunks
	li	IMW0(0)
	sgn
	cmp	r1

	//dhry_1.c, line 174
	cond	LE
					//conditional branch 			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l109)-1)
	li	IMW0(PCREL(l109))
		add	r7
				// freereg r2
l106: # 

	//dhry_1.c, line 175
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l20
	stdec	r6

	//dhry_1.c, line 175
					//call
	ldinc	r7
	.int	_puts
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 176
					//call
	ldinc	r7
	.int	_Proc_5
	exg	r7
				// constant: 0 in 1 chunks
	li	IMW0(0)
	add	r6


	//dhry_1.c, line 177
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l21
	stdec	r6

	//dhry_1.c, line 177
					//call
	ldinc	r7
	.int	_puts
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 178
					//call
	ldinc	r7
	.int	_Proc_4
	exg	r7
				// constant: 0 in 1 chunks
	li	IMW0(0)
	add	r6


	//dhry_1.c, line 180
					// (a/p assign)
					// (prepobj r1) var, auto|reg
	mt	r6
	mr	r1
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 2 in 1 chunks
	li	IMW0(2)
					// (save temp) store prepped reg
	st	r1
				//save_temp done

	//dhry_1.c, line 181
					// (a/p assign)
					// (prepobj r1) reg r4 - no need to prep
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 3 in 1 chunks
	li	IMW0(3)
					// (save temp) isreg
	mr	r4
				//save_temp done

	//dhry_1.c, line 182
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l22
	stdec	r6

	//dhry_1.c, line 182
					//call
	ldinc	r7
	.int	_puts
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 183
					// (a/p assign)
					// (prepobj r1) extern (offset 0)
	ldinc	r7
	.int	_Str_2_Loc
	mr	r1
// (char with size!=1 -> array of unknown type)
// Copying 31 bytes to Str_2_Loc
					// (load_temp - type 1) not varadr
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l23
	mr	r0
	mt	r2
	stdec	r6
				// constant: 1f in 1 chunks
	li	IMW0(31)
	addt	r1
	mr	r2
.cpyStr_2_Locloop2:
	ldbinc	r0
	stbinc	r1
	mt	r1
	cmp	r2
	cond	NEQ
		li	IMW0(PCREL(.cpyStr_2_Locloop2))
		add	r7
	ldinc	r6
	mr	r2

	//dhry_1.c, line 184
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l24
	stdec	r6

	//dhry_1.c, line 184
					//call
	ldinc	r7
	.int	_puts
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 185
					// (a/p assign)
					// (prepobj r1) var, auto|reg
				// constant: 8 in 1 chunks
	li	IMW0(8)
	addt	r6
	mr	r1

					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 1 in 1 chunks
	li	IMW0(1)
					// (save temp) store prepped reg
	st	r1
				//save_temp done

	//dhry_1.c, line 186
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l25
	stdec	r6

	//dhry_1.c, line 186
					//call
	ldinc	r7
	.int	_puts
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 187
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Str_2_Loc
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 187
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Str_1_Loc
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 187
					//call
	ldinc	r7
	.int	_Func_2
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6

				// allocreg r2

	//dhry_1.c, line 187
					// (getreturn)					// (save result) isreg
	mt	r0
	mr	r2

	//dhry_1.c, line 187
					// (test)
					// (objtotemp) reg r2
	mt	r2
	and	r2
				// freereg r2

	//dhry_1.c, line 187
	cond	NEQ
					//conditional branch 			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l26)-1)
	li	IMW0(PCREL(l26))
		add	r7
				// allocreg r2

	//dhry_1.c, line 187
					// (a/p assign)
					// (prepobj r1) reg r2 - no need to prep
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 1 in 1 chunks
	li	IMW0(1)
					// (save temp) isreg
	mr	r2
				//save_temp done

	//dhry_1.c, line 187
			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l27)-1)
	li	IMW0(PCREL(l27))
	add	r7
l26: # 

	//dhry_1.c, line 187
					// (a/p assign)
					// (prepobj r1) reg r2 - no need to prep
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 0 in 1 chunks
	li	IMW0(0)
					// (save temp) isreg
	mr	r2
				//save_temp done
l27: # 

	//dhry_1.c, line 187
					// (a/p assign)
					// (prepobj r1) extern (offset 0)
	ldinc	r7
	.int	_Bool_Glob
	mr	r1
					// (load_temp - type 3) not varadr
					// (objtotemp) reg r2
	mt	r2
					// (save temp) store prepped reg
	st	r1
				//save_temp done

	//dhry_1.c, line 189
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l29
	stdec	r6

	//dhry_1.c, line 189
					//call
	ldinc	r7
	.int	_puts
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 190
					// (compare) (q1 signed) (q2 signed)					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
	ld	r6
	mr	r1
					// (objtotemp) reg r4
	mt	r4
	sgn
	cmp	r1

	//dhry_1.c, line 190
	cond	GE
					//conditional branch 			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l110)-1)
	li	IMW0(PCREL(l110))
		add	r7
				// freereg r2
l107: # 
				// allocreg r2

	//dhry_1.c, line 192
					// (bitwise) loadreg
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
	ld	r6
	mr	r2
					// (objtotemp) const
				// constant: 5 in 1 chunks
	li	IMW0(5)
	mul	r2
					// (save result) isreg

	//dhry_1.c, line 192
					// (bitwise) loadreg
					// (objtotemp) reg r2
	mt	r2
	mr	r0
					// (objtotemp) reg r4
	mt	r4
	sub	r0
					// (save result) store reg
// Store_reg to type 0x3
					// (prepobj tmp) var, auto|reg
				// constant: 10 in 1 chunks
	li	IMW0(16)
	addt	r6
	stmpdec	r0
				// freereg r2
				// allocreg r2

	//dhry_1.c, line 194
					// (address)
					// (prepobj r2) var, auto|reg
				// constant: c in 1 chunks
	li	IMW0(12)
	addt	r6
	mr	r2

					// (save result) isreg

	//dhry_1.c, line 194
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) reg r2
	mt	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 194
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp) reg r4
	mt	r4
	stdec	r6

	//dhry_1.c, line 194
					// (a/p push)
					// a: pushed 8, regnames[sp] r6
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
				// constant: 8 in 1 chunks
	li	IMW0(8)
	ldidx	r6
	stdec	r6

	//dhry_1.c, line 194
					//call
	ldinc	r7
	.int	_Proc_7
	exg	r7
				// constant: c in 1 chunks
	li	IMW0(12)
	add	r6


	//dhry_1.c, line 196
					// (bitwise) loadreg
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
	ld	r6
	mr	r0
					// (objtotemp) const
				// constant: 1 in 1 chunks
	li	IMW0(1)
	add	r0
					// (save result) store reg
// Store_reg to type 0x3
					// (prepobj tmp) var, auto|reg
				// constant: 4 in 1 chunks
	li	IMW0(4)
	addt	r6
	stmpdec	r0

	//dhry_1.c, line 190
					// (compare) (q1 signed) (q2 signed)					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
	ld	r6
	mr	r1
					// (objtotemp) reg r4
	mt	r4
	sgn
	cmp	r1

	//dhry_1.c, line 190
	cond	SLT
					//conditional branch 			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l107)-1)
	li	IMW0(PCREL(l107))
		add	r7
l110: # 

	//dhry_1.c, line 199
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l33
	stdec	r6

	//dhry_1.c, line 199
					//call
	ldinc	r7
	.int	_puts
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 200
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
				// constant: c in 1 chunks
	li	IMW0(12)
	ldidx	r6
	stdec	r6

	//dhry_1.c, line 200
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
				// constant: 4 in 1 chunks
	li	IMW0(4)
	ldidx	r6
	stdec	r6

	//dhry_1.c, line 200
					// (a/p push)
					// a: pushed 8, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Arr_2_Glob
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 200
					// (a/p push)
					// a: pushed 12, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Arr_1_Glob
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 200
					//call
	ldinc	r7
	.int	_Proc_8
	exg	r7
				// constant: 10 in 1 chunks
	li	IMW0(16)
	add	r6


	//dhry_1.c, line 202
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l34
	stdec	r6

	//dhry_1.c, line 202
					//call
	ldinc	r7
	.int	_puts
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 203
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Ptr_Glob
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 203
					//call
	ldinc	r7
	.int	_Proc_1
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 204
					// (a/p assign)
					// (prepobj r1) var, auto|reg
				// constant: 4 in 1 chunks
	li	IMW0(4)
	addt	r6
	mr	r1

					// (load_temp - type 1) not varadr
					// (objtotemp) const
				// constant: 41 in 2 chunks
	li	IMW1(65)
	li	IMW0(65)
					// (save temp) store prepped reg
	stbinc	r1
//Disposable, postinc doesn't matter
				//save_temp done
				// allocreg r2

	//dhry_1.c, line 206
					//FIXME convert
					// (load_temp - type 1) not varadr
					// (objtotemp) extern
	ldinc	r7
	.int	_Ch_2_Glob
	byt
	ldt
	mr	r2
	li	24
	shl	r2
	sgn
	shr	r2
					// (save result) isreg

	//dhry_1.c, line 206
					// (compare) (q1 signed) (q2 signed)					// (objtotemp) reg r2
	mt	r2
	mr	r1
					// (objtotemp) const
				// constant: 41 in 2 chunks
	li	IMW1(65)
	li	IMW0(65)
	sgn
	cmp	r1
				// freereg r2

	//dhry_1.c, line 206
	cond	SLT
					//conditional branch 			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l111)-1)
	li	IMW0(PCREL(l111))
		add	r7
l108: # 

	//dhry_1.c, line 207
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: 43 in 2 chunks
	li	IMW1(67)
	li	IMW0(67)
	stdec	r6
				// allocreg r2

	//dhry_1.c, line 207
					//FIXME convert
					// (load_temp - type 1) not varadr
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x1
	byt
				// constant: 8 in 1 chunks
	li	IMW0(8)
	ldidx	r6
	mr	r2
	li	24
	shl	r2
	sgn
	shr	r2
					// (save result) isreg

	//dhry_1.c, line 207
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp) reg r2
	mt	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 207
					//call
	ldinc	r7
	.int	_Func_1
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6

				// allocreg r2

	//dhry_1.c, line 207
					// (getreturn)					// (save result) isreg
	mt	r0
	mr	r2

	//dhry_1.c, line 207
					// (compare) (q1 signed) (q2 signed)					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
				// constant: 8 in 1 chunks
	li	IMW0(8)
	ldidx	r6
	mr	r1
					// (objtotemp) reg r2
	mt	r2
	sgn
	cmp	r1
				// freereg r2

	//dhry_1.c, line 207
	cond	NEQ
					//conditional branch 			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l40)-1)
	li	IMW0(PCREL(l40))
		add	r7
				// allocreg r2

	//dhry_1.c, line 210
					// (address)
					// (prepobj r2) var, auto|reg
				// constant: 8 in 1 chunks
	li	IMW0(8)
	addt	r6
	mr	r2

					// (save result) isreg

	//dhry_1.c, line 210
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) reg r2
	mt	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 210
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp) const
				// constant: 0 in 1 chunks
	li	IMW0(0)
	stdec	r6

	//dhry_1.c, line 210
					//call
	ldinc	r7
	.int	_Proc_6
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 211
					// (a/p assign)
					// (prepobj r1) extern (offset 0)
	ldinc	r7
	.int	_Str_2_Loc
	mr	r1
// (char with size!=1 -> array of unknown type)
// Copying 31 bytes to Str_2_Loc
					// (load_temp - type 1) not varadr
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l41
	mr	r0
	mt	r2
	stdec	r6
				// constant: 1f in 1 chunks
	li	IMW0(31)
	addt	r1
	mr	r2
.cpyStr_2_Locloop3:
	ldbinc	r0
	stbinc	r1
	mt	r1
	cmp	r2
	cond	NEQ
		li	IMW0(PCREL(.cpyStr_2_Locloop3))
		add	r7
	ldinc	r6
	mr	r2

	//dhry_1.c, line 212
					// (a/p assign)
					// (prepobj r1) reg r4 - no need to prep
					// (load_temp - type 3) not varadr
					// (objtotemp) reg r5
	mt	r5
					// (save temp) isreg
	mr	r4
				//save_temp done

	//dhry_1.c, line 213
					// (a/p assign)
					// (prepobj r1) extern (offset 0)
	ldinc	r7
	.int	_Int_Glob
	mr	r1
					// (load_temp - type 3) not varadr
					// (objtotemp) reg r5
	mt	r5
					// (save temp) store prepped reg
	st	r1
				//save_temp done
l40: # 

	//dhry_1.c, line 206
					// (bitwise) loadreg
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x1
	byt
				// constant: 4 in 1 chunks
	li	IMW0(4)
	ldidx	r6
	mr	r0
					// (objtotemp) const
				// constant: 1 in 1 chunks
	li	IMW0(1)
	add	r0
					// (save result) store reg
// Store_reg to type 0x1
					// (prepobj tmp) var, auto|reg
				// constant: 4 in 1 chunks
	li	IMW0(4)
	addt	r6
	exg	r0
	stbinc	r0	//WARNING - pointer / reg not restored, might cause trouble!
				// allocreg r3

	//dhry_1.c, line 206
					//FIXME convert
					// (load_temp - type 1) not varadr
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x1
	byt
				// constant: 4 in 1 chunks
	li	IMW0(4)
	ldidx	r6
	mr	r3
	li	24
	shl	r3
	sgn
	shr	r3
					// (save result) isreg
				// allocreg r2

	//dhry_1.c, line 206
					//FIXME convert
					// (load_temp - type 1) not varadr
					// (objtotemp) extern
	ldinc	r7
	.int	_Ch_2_Glob
	byt
	ldt
	mr	r2
	li	24
	shl	r2
	sgn
	shr	r2
					// (save result) isreg

	//dhry_1.c, line 206
					// (compare) (q1 signed) (q2 signed)					// (objtotemp) reg r3
	mt	r3
	mr	r1
					// (objtotemp) reg r2
	mt	r2
	sgn
	cmp	r1
				// freereg r3
				// freereg r2

	//dhry_1.c, line 206
	cond	LE
					//conditional branch 			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l108)-1)
	li	IMW0(PCREL(l108))
		add	r7
l111: # 

	//dhry_1.c, line 216
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l42
	stdec	r6

	//dhry_1.c, line 216
					//call
	ldinc	r7
	.int	_puts
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 218
					// (bitwise) loadreg
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
	ld	r6
	mul	r4
					// (save result) isreg

	//dhry_1.c, line 219
					// (bitwise) loadreg
	//Call division routine
					// (objtotemp) reg r4
	mt	r4
	mr	r1
	mt	r2
	stdec	r6
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
				// constant: 10 in 1 chunks
	li	IMW0(16)
	ldidx	r6
	mr	r2
	ldinc	r7
	.int	_div_u32byu32
	exg	r7
	ldinc	r6
	mr	r2
	mt	r0
	mr	r0
					// (save result) store reg
// Store_reg to type 0x3
					// (prepobj tmp) var, auto|reg
				// constant: 4 in 1 chunks
	li	IMW0(4)
	addt	r6
	stmpdec	r0
				// allocreg r2

	//dhry_1.c, line 220
					// (bitwise) loadreg
					// (objtotemp) reg r4
	mt	r4
	mr	r2
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
				// constant: c in 1 chunks
	li	IMW0(12)
	ldidx	r6
	sub	r2
					// (save result) isreg

	//dhry_1.c, line 220
					// (bitwise) loadreg
					// (objtotemp) const
				// constant: 7 in 1 chunks
	li	IMW0(7)
	mul	r2
					// (save result) isreg

	//dhry_1.c, line 220
					// (bitwise) loadreg
					// (objtotemp) reg r2
	mt	r2
	mr	r4
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
	ld	r6
	sub	r4
					// (save result) isreg
				// freereg r2
				// allocreg r2

	//dhry_1.c, line 222
					// (address)
					// (prepobj r2) var, auto|reg
	mt	r6
	mr	r2
					// (save result) isreg

	//dhry_1.c, line 222
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) reg r2
	mt	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 222
					//call
	ldinc	r7
	.int	_Proc_2
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 174
					// (bitwise) loadreg
					// (objtotemp) const
				// constant: 1 in 1 chunks
	li	IMW0(1)
	add	r5
					// (save result) isreg

	//dhry_1.c, line 174
					// (compare) (q1 signed) (q2 signed)					// (objtotemp) reg r5
	mt	r5
	mr	r1
					// (objtotemp) extern
	ldinc	r7
	.int	_Number_Of_Runs
	ldt//marker 3
	sgn
	cmp	r1

	//dhry_1.c, line 174
	cond	LE
					//conditional branch 			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l106)-1)
	li	IMW0(PCREL(l106))
		add	r7
l109: # 

	//dhry_1.c, line 240
					//call
	ldinc	r7
	.int	__readMilliseconds
	exg	r7
				// constant: 0 in 1 chunks
	li	IMW0(0)
	add	r6


	//dhry_1.c, line 240
					// (getreturn)					// (save result) store reg
// Store_reg to type 0x4
					// (prepobj tmp) extern (offset 0)
	ldinc	r7
	.int	_End_Time
	stmpdec	r0

	//dhry_1.c, line 244
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l43
	stdec	r6

	//dhry_1.c, line 244
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 245
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l44
	stdec	r6

	//dhry_1.c, line 245
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 246
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l45
	stdec	r6

	//dhry_1.c, line 246
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 247
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l46
	stdec	r6

	//dhry_1.c, line 247
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 248
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Int_Glob
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 248
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l47
	stdec	r6

	//dhry_1.c, line 248
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 249
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: 5 in 1 chunks
	li	IMW0(5)
	stdec	r6

	//dhry_1.c, line 249
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l48
	stdec	r6

	//dhry_1.c, line 249
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 250
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Bool_Glob
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 250
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l49
	stdec	r6

	//dhry_1.c, line 250
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 251
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: 1 in 1 chunks
	li	IMW0(1)
	stdec	r6

	//dhry_1.c, line 251
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l50
	stdec	r6

	//dhry_1.c, line 251
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6

				// allocreg r2

	//dhry_1.c, line 252
					//FIXME convert
					// (load_temp - type 1) not varadr
					// (objtotemp) extern
	ldinc	r7
	.int	_Ch_1_Glob
	byt
	ldt
	mr	r2
	li	24
	shl	r2
	sgn
	shr	r2
					// (save result) isreg

	//dhry_1.c, line 252
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) reg r2
	mt	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 252
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l51
	stdec	r6

	//dhry_1.c, line 252
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 253
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: 41 in 2 chunks
	li	IMW1(65)
	li	IMW0(65)
	stdec	r6

	//dhry_1.c, line 253
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l52
	stdec	r6

	//dhry_1.c, line 253
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6

				// allocreg r2

	//dhry_1.c, line 254
					//FIXME convert
					// (load_temp - type 1) not varadr
					// (objtotemp) extern
	ldinc	r7
	.int	_Ch_2_Glob
	byt
	ldt
	mr	r2
	li	24
	shl	r2
	sgn
	shr	r2
					// (save result) isreg

	//dhry_1.c, line 254
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) reg r2
	mt	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 254
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l53
	stdec	r6

	//dhry_1.c, line 254
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 255
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: 42 in 2 chunks
	li	IMW1(66)
	li	IMW0(66)
	stdec	r6

	//dhry_1.c, line 255
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l54
	stdec	r6

	//dhry_1.c, line 255
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 256
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Arr_1_Glob + 32
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 256
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l55
	stdec	r6

	//dhry_1.c, line 256
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 257
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: 7 in 1 chunks
	li	IMW0(7)
	stdec	r6

	//dhry_1.c, line 257
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l56
	stdec	r6

	//dhry_1.c, line 257
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 258
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Arr_2_Glob + 1628
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 258
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l57
	stdec	r6

	//dhry_1.c, line 258
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 259
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l58
	stdec	r6

	//dhry_1.c, line 259
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 260
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l59
	stdec	r6

	//dhry_1.c, line 260
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 261
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) deref 
					// (prepobj tmp) deref  var FIXME - deref? FIXME - deref?	ldinc	r7
	.int	_Ptr_Glob
		//sizemod based on type 0x3
	ldt
//marker 2
	stdec	r6

	//dhry_1.c, line 261
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l60
	stdec	r6

	//dhry_1.c, line 261
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 262
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l61
	stdec	r6

	//dhry_1.c, line 262
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6

				// allocreg r2

	//dhry_1.c, line 263
					// (bitwise) loadreg
					// (objtotemp) extern
	ldinc	r7
	.int	_Ptr_Glob
	ldt//marker 3
	mr	r2
					// (objtotemp) const
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r2
					// (save result) isreg

	//dhry_1.c, line 263
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) deref 
	ld	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 263
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l62
	stdec	r6

	//dhry_1.c, line 263
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 264
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: 0 in 1 chunks
	li	IMW0(0)
	stdec	r6

	//dhry_1.c, line 264
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l63
	stdec	r6

	//dhry_1.c, line 264
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6

				// allocreg r2

	//dhry_1.c, line 265
					// (bitwise) loadreg
					// (objtotemp) extern
	ldinc	r7
	.int	_Ptr_Glob
	ldt//marker 3
	mr	r2
					// (objtotemp) const
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r2
					// (save result) isreg

	//dhry_1.c, line 265
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) deref 
	ld	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 265
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l64
	stdec	r6

	//dhry_1.c, line 265
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 266
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: 2 in 1 chunks
	li	IMW0(2)
	stdec	r6

	//dhry_1.c, line 266
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l65
	stdec	r6

	//dhry_1.c, line 266
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6

				// allocreg r2

	//dhry_1.c, line 267
					// (bitwise) loadreg
					// (objtotemp) extern
	ldinc	r7
	.int	_Ptr_Glob
	ldt//marker 3
	mr	r2
					// (objtotemp) const
				// constant: c in 1 chunks
	li	IMW0(12)
	add	r2
					// (save result) isreg

	//dhry_1.c, line 267
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) deref 
	ld	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 267
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l66
	stdec	r6

	//dhry_1.c, line 267
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 268
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: 11 in 1 chunks
	li	IMW0(17)
	stdec	r6

	//dhry_1.c, line 268
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l67
	stdec	r6

	//dhry_1.c, line 268
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6

				// allocreg r2

	//dhry_1.c, line 269
					// (bitwise) loadreg
					// (objtotemp) extern
	ldinc	r7
	.int	_Ptr_Glob
	ldt//marker 3
	mr	r2
					// (objtotemp) const
				// constant: 10 in 1 chunks
	li	IMW0(16)
	add	r2
					// (save result) isreg

	//dhry_1.c, line 269
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) reg r2
	mt	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 269
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l68
	stdec	r6

	//dhry_1.c, line 269
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 270
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l69
	stdec	r6

	//dhry_1.c, line 270
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 271
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l70
	stdec	r6

	//dhry_1.c, line 271
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 272
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) deref 
					// (prepobj tmp) deref  var FIXME - deref? FIXME - deref?	ldinc	r7
	.int	_Next_Ptr_Glob
		//sizemod based on type 0x3
	ldt
//marker 2
	stdec	r6

	//dhry_1.c, line 272
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l71
	stdec	r6

	//dhry_1.c, line 272
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 273
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l72
	stdec	r6

	//dhry_1.c, line 273
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6

				// allocreg r2

	//dhry_1.c, line 274
					// (bitwise) loadreg
					// (objtotemp) extern
	ldinc	r7
	.int	_Next_Ptr_Glob
	ldt//marker 3
	mr	r2
					// (objtotemp) const
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r2
					// (save result) isreg

	//dhry_1.c, line 274
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) deref 
	ld	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 274
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l73
	stdec	r6

	//dhry_1.c, line 274
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 275
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: 0 in 1 chunks
	li	IMW0(0)
	stdec	r6

	//dhry_1.c, line 275
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l74
	stdec	r6

	//dhry_1.c, line 275
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6

				// allocreg r2

	//dhry_1.c, line 276
					// (bitwise) loadreg
					// (objtotemp) extern
	ldinc	r7
	.int	_Next_Ptr_Glob
	ldt//marker 3
	mr	r2
					// (objtotemp) const
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r2
					// (save result) isreg

	//dhry_1.c, line 276
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) deref 
	ld	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 276
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l75
	stdec	r6

	//dhry_1.c, line 276
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 277
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: 1 in 1 chunks
	li	IMW0(1)
	stdec	r6

	//dhry_1.c, line 277
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l76
	stdec	r6

	//dhry_1.c, line 277
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6

				// allocreg r2

	//dhry_1.c, line 278
					// (bitwise) loadreg
					// (objtotemp) extern
	ldinc	r7
	.int	_Next_Ptr_Glob
	ldt//marker 3
	mr	r2
					// (objtotemp) const
				// constant: c in 1 chunks
	li	IMW0(12)
	add	r2
					// (save result) isreg

	//dhry_1.c, line 278
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) deref 
	ld	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 278
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l77
	stdec	r6

	//dhry_1.c, line 278
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 279
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: 12 in 1 chunks
	li	IMW0(18)
	stdec	r6

	//dhry_1.c, line 279
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l78
	stdec	r6

	//dhry_1.c, line 279
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6

				// allocreg r2

	//dhry_1.c, line 281
					// (bitwise) loadreg
					// (objtotemp) extern
	ldinc	r7
	.int	_Next_Ptr_Glob
	ldt//marker 3
	mr	r2
					// (objtotemp) const
				// constant: 10 in 1 chunks
	li	IMW0(16)
	add	r2
					// (save result) isreg

	//dhry_1.c, line 281
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) reg r2
	mt	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 281
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l79
	stdec	r6

	//dhry_1.c, line 281
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 282
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l80
	stdec	r6

	//dhry_1.c, line 282
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 283
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
	ld	r6
	stdec	r6

	//dhry_1.c, line 283
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l81
	stdec	r6

	//dhry_1.c, line 283
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 284
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: 5 in 1 chunks
	li	IMW0(5)
	stdec	r6

	//dhry_1.c, line 284
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l82
	stdec	r6

	//dhry_1.c, line 284
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 285
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) reg r4
	mt	r4
	stdec	r6

	//dhry_1.c, line 285
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l83
	stdec	r6

	//dhry_1.c, line 285
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 286
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: d in 1 chunks
	li	IMW0(13)
	stdec	r6

	//dhry_1.c, line 286
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l84
	stdec	r6

	//dhry_1.c, line 286
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 287
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
				// constant: c in 1 chunks
	li	IMW0(12)
	ldidx	r6
	stdec	r6

	//dhry_1.c, line 287
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l85
	stdec	r6

	//dhry_1.c, line 287
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 288
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: 7 in 1 chunks
	li	IMW0(7)
	stdec	r6

	//dhry_1.c, line 288
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l86
	stdec	r6

	//dhry_1.c, line 288
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 289
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
				// constant: 8 in 1 chunks
	li	IMW0(8)
	ldidx	r6
	stdec	r6

	//dhry_1.c, line 289
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l87
	stdec	r6

	//dhry_1.c, line 289
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 290
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) const
				// constant: 1 in 1 chunks
	li	IMW0(1)
	stdec	r6

	//dhry_1.c, line 290
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l88
	stdec	r6

	//dhry_1.c, line 290
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 291
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Str_1_Loc
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 291
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l89
	stdec	r6

	//dhry_1.c, line 291
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 292
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l90
	stdec	r6

	//dhry_1.c, line 292
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 293
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Str_2_Loc
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 293
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l91
	stdec	r6

	//dhry_1.c, line 293
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 294
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l92
	stdec	r6

	//dhry_1.c, line 294
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 295
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l93
	stdec	r6

	//dhry_1.c, line 295
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6

				// allocreg r2

	//dhry_1.c, line 298
					// (bitwise) loadreg
					// (objtotemp) extern
	ldinc	r7
	.int	_End_Time
	ldt//marker 3
	mr	r2
					// (objtotemp) extern
	ldinc	r7
	.int	_Begin_Time
	ldt//marker 3
	sub	r2
					// (save result) isreg
					// (a/p assign)
					// (prepobj r1) extern (offset 0)
	ldinc	r7
	.int	_User_Time
	mr	r1
					// (load_temp - type 4) not varadr
					// (objtotemp) reg r2
	mt	r2
					// (save temp) store prepped reg
	st	r1
				//save_temp done

	//dhry_1.c, line 299
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) reg r2
	mt	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 299
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l94
	stdec	r6

	//dhry_1.c, line 299
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 301
					// (compare) (q1 signed) (q2 signed)					// (objtotemp) extern
	ldinc	r7
	.int	_User_Time
	ldt//marker 3
	mr	r1
					// (objtotemp) const
				// constant: 78 in 2 chunks
	li	IMW1(120)
	li	IMW0(120)
	sgn
	cmp	r1

	//dhry_1.c, line 301
	cond	GE
					//conditional branch 			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l96)-1)
	li	IMW0(PCREL(l96))
		add	r7
				// allocreg r2

	//dhry_1.c, line 303
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l97
	stdec	r6

	//dhry_1.c, line 303
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 304
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l98
	stdec	r6

	//dhry_1.c, line 304
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 305
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l99
	stdec	r6

	//dhry_1.c, line 305
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6

				// freereg r2
				// freereg r4
l96: # 
				// allocreg r2
					// (a/p assign)
					// (prepobj r1) reg r2 - no need to prep
					// (load_temp - type 4) not varadr
					// (objtotemp) extern
	ldinc	r7
	.int	_User_Time
	ldt//marker 3
					// (save temp) isreg
	mr	r2
				//save_temp done
				// allocreg r3

	//dhry_1.c, line 323
					// (bitwise) loadreg
					// (objtotemp) reg r2
	mt	r2
	mr	r3
					// (objtotemp) const
				// constant: 3e8 in 2 chunks
	li	IMW1(1000)
	li	IMW0(1000)
	mul	r3
					// (save result) isreg

	//dhry_1.c, line 323
					// (bitwise) loadreg
	//Call division routine
					// (objtotemp) reg r3
	mt	r3
	mr	r1
	mt	r2
	stdec	r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Number_Of_Runs
	ldt//marker 3
	mr	r2
	ldinc	r7
	.int	_div_u32byu32
	exg	r7
	ldinc	r6
	mr	r2
	mt	r0
	mr	r0
					// (save result) store reg
// Store_reg to type 0x4
					// (prepobj tmp) extern (offset 0)
	ldinc	r7
	.int	_Microseconds
	stmpdec	r0
				// freereg r3
				// allocreg r3
					// (a/p assign)
					// (prepobj r1) reg r3 - no need to prep
					// (load_temp - type 3) not varadr
					// (objtotemp) extern
	ldinc	r7
	.int	_Number_Of_Runs
	ldt//marker 3
					// (save temp) isreg
	mr	r3
				//save_temp done
				// allocreg r4

	//dhry_1.c, line 324
					// (bitwise) loadreg
					// (objtotemp) reg r3
	mt	r3
	mr	r4
					// (objtotemp) const
				// constant: 3e8 in 2 chunks
	li	IMW1(1000)
	li	IMW0(1000)
	mul	r4
					// (save result) isreg

	//dhry_1.c, line 324
					// (bitwise) loadreg
	//Call division routine
					// (objtotemp) reg r4
	mt	r4
	mr	r1
	mt	r2
	stdec	r6
					// (objtotemp) reg r2
	mt	r2
	mr	r2
	ldinc	r7
	.int	_div_u32byu32
	exg	r7
	ldinc	r6
	mr	r2
	mt	r0
	mr	r0
					// (save result) store reg
// Store_reg to type 0x4
					// (prepobj tmp) extern (offset 0)
	ldinc	r7
	.int	_Dhrystones_Per_Second
	stmpdec	r0
				// freereg r4

	//dhry_1.c, line 325
					// (bitwise) loadreg
					// (objtotemp) const
				// constant: 239 in 2 chunks
	li	IMW1(569)
	li	IMW0(569)
	mul	r3
					// (save result) isreg

	//dhry_1.c, line 325
					// (bitwise) loadreg
	//Call division routine
					// (objtotemp) reg r3
	mt	r3
	mr	r1
	mt	r2
	stdec	r6
					// (objtotemp) reg r2
	mt	r2
	mr	r2
	ldinc	r7
	.int	_div_u32byu32
	exg	r7
	ldinc	r6
	mr	r2
	mt	r0
	mr	r0
					// (save result) store reg
// Store_reg to type 0x4
					// (prepobj tmp) extern (offset 0)
	ldinc	r7
	.int	_Vax_Mips
	stmpdec	r0
				// freereg r3
				// freereg r2

	//dhry_1.c, line 327
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l100
	stdec	r6

	//dhry_1.c, line 327
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 328
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Microseconds
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 328
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l101
	stdec	r6

	//dhry_1.c, line 328
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 329
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l102
	stdec	r6

	//dhry_1.c, line 329
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 330
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Dhrystones_Per_Second
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 330
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l103
	stdec	r6

	//dhry_1.c, line 330
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 331
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Vax_Mips
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 331
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l104
	stdec	r6

	//dhry_1.c, line 331
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 332
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp)//static
				//statictotemp
	ldinc	r7
	.int	l105
	stdec	r6

	//dhry_1.c, line 332
					//call
	ldinc	r7
	.int	_small_printf
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 335
					//setreturn
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 0 in 1 chunks
	li	IMW0(0)
	mr	r0
				// freereg r5
				// constant: 10 in 1 chunks
	li	IMW0(16)
	add	r6
	ldinc	r6
	mr	r5
	ldinc	r6
	mr	r4
	ldinc	r6
	mr	r3
	ldinc	r6
	mr	r2
	ldinc	r6
	mr	r7

// stacksize=0+??
	.section	.rodata
l10:
	.byte	80
	.byte	114
	.byte	111
	.byte	103
	.byte	114
	.byte	97
	.byte	109
	.byte	32
	.byte	99
	.byte	111
	.byte	109
	.byte	112
	.byte	105
	.byte	108
	.byte	101
	.byte	100
	.byte	32
	.byte	119
	.byte	105
	.byte	116
	.byte	104
	.byte	32
	.byte	39
	.byte	114
	.byte	101
	.byte	103
	.byte	105
	.byte	115
	.byte	116
	.byte	101
	.byte	114
	.byte	39
	.byte	32
	.byte	97
	.byte	116
	.byte	116
	.byte	114
	.byte	105
	.byte	98
	.byte	117
	.byte	116
	.byte	101
	.byte	10
	.byte	0
l11:
	.byte	10
	.byte	0
l13:
	.byte	80
	.byte	114
	.byte	111
	.byte	103
	.byte	114
	.byte	97
	.byte	109
	.byte	32
	.byte	99
	.byte	111
	.byte	109
	.byte	112
	.byte	105
	.byte	108
	.byte	101
	.byte	100
	.byte	32
	.byte	119
	.byte	105
	.byte	116
	.byte	104
	.byte	111
	.byte	117
	.byte	116
	.byte	32
	.byte	39
	.byte	114
	.byte	101
	.byte	103
	.byte	105
	.byte	115
	.byte	116
	.byte	101
	.byte	114
	.byte	39
	.byte	32
	.byte	97
	.byte	116
	.byte	116
	.byte	114
	.byte	105
	.byte	98
	.byte	117
	.byte	116
	.byte	101
	.byte	10
	.byte	0
l14:
	.byte	10
	.byte	0
l41:
	.byte	68
	.byte	72
	.byte	82
	.byte	89
	.byte	83
	.byte	84
	.byte	79
	.byte	78
	.byte	69
	.byte	32
	.byte	80
	.byte	82
	.byte	79
	.byte	71
	.byte	82
	.byte	65
	.byte	77
	.byte	44
	.byte	32
	.byte	51
	.byte	39
	.byte	82
	.byte	68
	.byte	32
	.byte	83
	.byte	84
	.byte	82
	.byte	73
	.byte	78
	.byte	71
	.byte	0
l20:
	.byte	53
	.byte	10
	.byte	0
l21:
	.byte	52
	.byte	10
	.byte	0
l22:
	.byte	50
	.byte	10
	.byte	0
l23:
	.byte	68
	.byte	72
	.byte	82
	.byte	89
	.byte	83
	.byte	84
	.byte	79
	.byte	78
	.byte	69
	.byte	32
	.byte	80
	.byte	82
	.byte	79
	.byte	71
	.byte	82
	.byte	65
	.byte	77
	.byte	44
	.byte	32
	.byte	50
	.byte	39
	.byte	78
	.byte	68
	.byte	32
	.byte	83
	.byte	84
	.byte	82
	.byte	73
	.byte	78
	.byte	71
	.byte	0
l24:
	.byte	50
	.byte	46
	.byte	49
	.byte	10
	.byte	0
l25:
	.byte	50
	.byte	46
	.byte	50
	.byte	10
	.byte	0
l29:
	.byte	49
	.byte	10
	.byte	0
l33:
	.byte	65
	.byte	10
	.byte	0
l34:
	.byte	66
	.byte	10
	.byte	0
l42:
	.byte	67
	.byte	10
	.byte	0
l97:
	.byte	77
	.byte	101
	.byte	97
	.byte	115
	.byte	117
	.byte	114
	.byte	101
	.byte	100
	.byte	32
	.byte	116
	.byte	105
	.byte	109
	.byte	101
	.byte	32
	.byte	116
	.byte	111
	.byte	111
	.byte	32
	.byte	115
	.byte	109
	.byte	97
	.byte	108
	.byte	108
	.byte	32
	.byte	116
	.byte	111
	.byte	32
	.byte	111
	.byte	98
	.byte	116
	.byte	97
	.byte	105
	.byte	110
	.byte	32
	.byte	109
	.byte	101
	.byte	97
	.byte	110
	.byte	105
	.byte	110
	.byte	103
	.byte	102
	.byte	117
	.byte	108
	.byte	32
	.byte	114
	.byte	101
	.byte	115
	.byte	117
	.byte	108
	.byte	116
	.byte	115
	.byte	10
	.byte	0
l98:
	.byte	80
	.byte	108
	.byte	101
	.byte	97
	.byte	115
	.byte	101
	.byte	32
	.byte	105
	.byte	110
	.byte	99
	.byte	114
	.byte	101
	.byte	97
	.byte	115
	.byte	101
	.byte	32
	.byte	110
	.byte	117
	.byte	109
	.byte	98
	.byte	101
	.byte	114
	.byte	32
	.byte	111
	.byte	102
	.byte	32
	.byte	114
	.byte	117
	.byte	110
	.byte	115
	.byte	10
	.byte	0
l99:
	.byte	10
	.byte	0
l100:
	.byte	77
	.byte	105
	.byte	99
	.byte	114
	.byte	111
	.byte	115
	.byte	101
	.byte	99
	.byte	111
	.byte	110
	.byte	100
	.byte	115
	.byte	32
	.byte	102
	.byte	111
	.byte	114
	.byte	32
	.byte	111
	.byte	110
	.byte	101
	.byte	32
	.byte	114
	.byte	117
	.byte	110
	.byte	32
	.byte	116
	.byte	104
	.byte	114
	.byte	111
	.byte	117
	.byte	103
	.byte	104
	.byte	32
	.byte	68
	.byte	104
	.byte	114
	.byte	121
	.byte	115
	.byte	116
	.byte	111
	.byte	110
	.byte	101
	.byte	58
	.byte	32
	.byte	0
l101:
	.byte	37
	.byte	100
	.byte	32
	.byte	10
	.byte	0
l102:
	.byte	68
	.byte	104
	.byte	114
	.byte	121
	.byte	115
	.byte	116
	.byte	111
	.byte	110
	.byte	101
	.byte	115
	.byte	32
	.byte	112
	.byte	101
	.byte	114
	.byte	32
	.byte	83
	.byte	101
	.byte	99
	.byte	111
	.byte	110
	.byte	100
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	0
l103:
	.byte	37
	.byte	100
	.byte	32
	.byte	10
	.byte	0
l104:
	.byte	86
	.byte	65
	.byte	88
	.byte	32
	.byte	77
	.byte	73
	.byte	80
	.byte	83
	.byte	32
	.byte	114
	.byte	97
	.byte	116
	.byte	105
	.byte	110
	.byte	103
	.byte	32
	.byte	42
	.byte	32
	.byte	49
	.byte	48
	.byte	48
	.byte	48
	.byte	32
	.byte	61
	.byte	32
	.byte	37
	.byte	100
	.byte	32
	.byte	10
	.byte	0
l105:
	.byte	10
	.byte	0
l3:
	.byte	68
	.byte	72
	.byte	82
	.byte	89
	.byte	83
	.byte	84
	.byte	79
	.byte	78
	.byte	69
	.byte	32
	.byte	80
	.byte	82
	.byte	79
	.byte	71
	.byte	82
	.byte	65
	.byte	77
	.byte	44
	.byte	32
	.byte	83
	.byte	79
	.byte	77
	.byte	69
	.byte	32
	.byte	83
	.byte	84
	.byte	82
	.byte	73
	.byte	78
	.byte	71
	.byte	0
l4:
	.byte	68
	.byte	72
	.byte	82
	.byte	89
	.byte	83
	.byte	84
	.byte	79
	.byte	78
	.byte	69
	.byte	32
	.byte	80
	.byte	82
	.byte	79
	.byte	71
	.byte	82
	.byte	65
	.byte	77
	.byte	44
	.byte	32
	.byte	49
	.byte	39
	.byte	83
	.byte	84
	.byte	32
	.byte	83
	.byte	84
	.byte	82
	.byte	73
	.byte	78
	.byte	71
	.byte	0
l5:
	.byte	10
	.byte	0
l6:
	.byte	68
	.byte	104
	.byte	114
	.byte	121
	.byte	115
	.byte	116
	.byte	111
	.byte	110
	.byte	101
	.byte	32
	.byte	66
	.byte	101
	.byte	110
	.byte	99
	.byte	104
	.byte	109
	.byte	97
	.byte	114
	.byte	107
	.byte	44
	.byte	32
	.byte	86
	.byte	101
	.byte	114
	.byte	115
	.byte	105
	.byte	111
	.byte	110
	.byte	32
	.byte	50
	.byte	46
	.byte	49
	.byte	32
	.byte	40
	.byte	76
	.byte	97
	.byte	110
	.byte	103
	.byte	117
	.byte	97
	.byte	103
	.byte	101
	.byte	58
	.byte	32
	.byte	67
	.byte	41
	.byte	10
	.byte	0
l7:
	.byte	10
	.byte	0
l15:
	.byte	69
	.byte	120
	.byte	101
	.byte	99
	.byte	117
	.byte	116
	.byte	105
	.byte	111
	.byte	110
	.byte	32
	.byte	115
	.byte	116
	.byte	97
	.byte	114
	.byte	116
	.byte	115
	.byte	44
	.byte	32
	.byte	37
	.byte	100
	.byte	32
	.byte	114
	.byte	117
	.byte	110
	.byte	115
	.byte	32
	.byte	116
	.byte	104
	.byte	114
	.byte	111
	.byte	117
	.byte	103
	.byte	104
	.byte	32
	.byte	68
	.byte	104
	.byte	114
	.byte	121
	.byte	115
	.byte	116
	.byte	111
	.byte	110
	.byte	101
	.byte	10
	.byte	0
l43:
	.byte	69
	.byte	120
	.byte	101
	.byte	99
	.byte	117
	.byte	116
	.byte	105
	.byte	111
	.byte	110
	.byte	32
	.byte	101
	.byte	110
	.byte	100
	.byte	115
	.byte	10
	.byte	0
l44:
	.byte	10
	.byte	0
l45:
	.byte	70
	.byte	105
	.byte	110
	.byte	97
	.byte	108
	.byte	32
	.byte	118
	.byte	97
	.byte	108
	.byte	117
	.byte	101
	.byte	115
	.byte	32
	.byte	111
	.byte	102
	.byte	32
	.byte	116
	.byte	104
	.byte	101
	.byte	32
	.byte	118
	.byte	97
	.byte	114
	.byte	105
	.byte	97
	.byte	98
	.byte	108
	.byte	101
	.byte	115
	.byte	32
	.byte	117
	.byte	115
	.byte	101
	.byte	100
	.byte	32
	.byte	105
	.byte	110
	.byte	32
	.byte	116
	.byte	104
	.byte	101
	.byte	32
	.byte	98
	.byte	101
	.byte	110
	.byte	99
	.byte	104
	.byte	109
	.byte	97
	.byte	114
	.byte	107
	.byte	58
	.byte	10
	.byte	0
l46:
	.byte	10
	.byte	0
l47:
	.byte	73
	.byte	110
	.byte	116
	.byte	95
	.byte	71
	.byte	108
	.byte	111
	.byte	98
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l48:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l49:
	.byte	66
	.byte	111
	.byte	111
	.byte	108
	.byte	95
	.byte	71
	.byte	108
	.byte	111
	.byte	98
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l50:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l51:
	.byte	67
	.byte	104
	.byte	95
	.byte	49
	.byte	95
	.byte	71
	.byte	108
	.byte	111
	.byte	98
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	99
	.byte	10
	.byte	0
l52:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	99
	.byte	10
	.byte	0
l53:
	.byte	67
	.byte	104
	.byte	95
	.byte	50
	.byte	95
	.byte	71
	.byte	108
	.byte	111
	.byte	98
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	99
	.byte	10
	.byte	0
l54:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	99
	.byte	10
	.byte	0
l55:
	.byte	65
	.byte	114
	.byte	114
	.byte	95
	.byte	49
	.byte	95
	.byte	71
	.byte	108
	.byte	111
	.byte	98
	.byte	91
	.byte	56
	.byte	93
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l56:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l57:
	.byte	65
	.byte	114
	.byte	114
	.byte	95
	.byte	50
	.byte	95
	.byte	71
	.byte	108
	.byte	111
	.byte	98
	.byte	91
	.byte	56
	.byte	93
	.byte	91
	.byte	55
	.byte	93
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l58:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	78
	.byte	117
	.byte	109
	.byte	98
	.byte	101
	.byte	114
	.byte	95
	.byte	79
	.byte	102
	.byte	95
	.byte	82
	.byte	117
	.byte	110
	.byte	115
	.byte	32
	.byte	43
	.byte	32
	.byte	49
	.byte	48
	.byte	10
	.byte	0
l59:
	.byte	80
	.byte	116
	.byte	114
	.byte	95
	.byte	71
	.byte	108
	.byte	111
	.byte	98
	.byte	45
	.byte	62
	.byte	10
	.byte	0
l60:
	.byte	32
	.byte	32
	.byte	80
	.byte	116
	.byte	114
	.byte	95
	.byte	67
	.byte	111
	.byte	109
	.byte	112
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l61:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	40
	.byte	105
	.byte	109
	.byte	112
	.byte	108
	.byte	101
	.byte	109
	.byte	101
	.byte	110
	.byte	116
	.byte	97
	.byte	116
	.byte	105
	.byte	111
	.byte	110
	.byte	45
	.byte	100
	.byte	101
	.byte	112
	.byte	101
	.byte	110
	.byte	100
	.byte	101
	.byte	110
	.byte	116
	.byte	41
	.byte	10
	.byte	0
l62:
	.byte	32
	.byte	32
	.byte	68
	.byte	105
	.byte	115
	.byte	99
	.byte	114
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l63:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l64:
	.byte	32
	.byte	32
	.byte	69
	.byte	110
	.byte	117
	.byte	109
	.byte	95
	.byte	67
	.byte	111
	.byte	109
	.byte	112
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l65:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l66:
	.byte	32
	.byte	32
	.byte	73
	.byte	110
	.byte	116
	.byte	95
	.byte	67
	.byte	111
	.byte	109
	.byte	112
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l67:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l68:
	.byte	32
	.byte	32
	.byte	83
	.byte	116
	.byte	114
	.byte	95
	.byte	67
	.byte	111
	.byte	109
	.byte	112
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	115
	.byte	10
	.byte	0
l69:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	68
	.byte	72
	.byte	82
	.byte	89
	.byte	83
	.byte	84
	.byte	79
	.byte	78
	.byte	69
	.byte	32
	.byte	80
	.byte	82
	.byte	79
	.byte	71
	.byte	82
	.byte	65
	.byte	77
	.byte	44
	.byte	32
	.byte	83
	.byte	79
	.byte	77
	.byte	69
	.byte	32
	.byte	83
	.byte	84
	.byte	82
	.byte	73
	.byte	78
	.byte	71
	.byte	10
	.byte	0
l70:
	.byte	78
	.byte	101
	.byte	120
	.byte	116
	.byte	95
	.byte	80
	.byte	116
	.byte	114
	.byte	95
	.byte	71
	.byte	108
	.byte	111
	.byte	98
	.byte	45
	.byte	62
	.byte	10
	.byte	0
l71:
	.byte	32
	.byte	32
	.byte	80
	.byte	116
	.byte	114
	.byte	95
	.byte	67
	.byte	111
	.byte	109
	.byte	112
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l72:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	40
	.byte	105
	.byte	109
	.byte	112
	.byte	108
	.byte	101
	.byte	109
	.byte	101
	.byte	110
	.byte	116
	.byte	97
	.byte	116
	.byte	105
	.byte	111
	.byte	110
	.byte	45
	.byte	100
	.byte	101
	.byte	112
	.byte	101
	.byte	110
	.byte	100
	.byte	101
	.byte	110
	.byte	116
	.byte	41
	.byte	44
	.byte	32
	.byte	115
	.byte	97
	.byte	109
	.byte	101
	.byte	32
	.byte	97
	.byte	115
	.byte	32
	.byte	97
	.byte	98
	.byte	111
	.byte	118
	.byte	101
	.byte	10
	.byte	0
l73:
	.byte	32
	.byte	32
	.byte	68
	.byte	105
	.byte	115
	.byte	99
	.byte	114
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l74:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l75:
	.byte	32
	.byte	32
	.byte	69
	.byte	110
	.byte	117
	.byte	109
	.byte	95
	.byte	67
	.byte	111
	.byte	109
	.byte	112
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l76:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l77:
	.byte	32
	.byte	32
	.byte	73
	.byte	110
	.byte	116
	.byte	95
	.byte	67
	.byte	111
	.byte	109
	.byte	112
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l78:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l79:
	.byte	32
	.byte	32
	.byte	83
	.byte	116
	.byte	114
	.byte	95
	.byte	67
	.byte	111
	.byte	109
	.byte	112
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	115
	.byte	10
	.byte	0
l80:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	68
	.byte	72
	.byte	82
	.byte	89
	.byte	83
	.byte	84
	.byte	79
	.byte	78
	.byte	69
	.byte	32
	.byte	80
	.byte	82
	.byte	79
	.byte	71
	.byte	82
	.byte	65
	.byte	77
	.byte	44
	.byte	32
	.byte	83
	.byte	79
	.byte	77
	.byte	69
	.byte	32
	.byte	83
	.byte	84
	.byte	82
	.byte	73
	.byte	78
	.byte	71
	.byte	10
	.byte	0
l81:
	.byte	73
	.byte	110
	.byte	116
	.byte	95
	.byte	49
	.byte	95
	.byte	76
	.byte	111
	.byte	99
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l82:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l83:
	.byte	73
	.byte	110
	.byte	116
	.byte	95
	.byte	50
	.byte	95
	.byte	76
	.byte	111
	.byte	99
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l84:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l85:
	.byte	73
	.byte	110
	.byte	116
	.byte	95
	.byte	51
	.byte	95
	.byte	76
	.byte	111
	.byte	99
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l86:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l87:
	.byte	69
	.byte	110
	.byte	117
	.byte	109
	.byte	95
	.byte	76
	.byte	111
	.byte	99
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l88:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
l89:
	.byte	83
	.byte	116
	.byte	114
	.byte	95
	.byte	49
	.byte	95
	.byte	76
	.byte	111
	.byte	99
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	115
	.byte	10
	.byte	0
l90:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	68
	.byte	72
	.byte	82
	.byte	89
	.byte	83
	.byte	84
	.byte	79
	.byte	78
	.byte	69
	.byte	32
	.byte	80
	.byte	82
	.byte	79
	.byte	71
	.byte	82
	.byte	65
	.byte	77
	.byte	44
	.byte	32
	.byte	49
	.byte	39
	.byte	83
	.byte	84
	.byte	32
	.byte	83
	.byte	84
	.byte	82
	.byte	73
	.byte	78
	.byte	71
	.byte	10
	.byte	0
l91:
	.byte	83
	.byte	116
	.byte	114
	.byte	95
	.byte	50
	.byte	95
	.byte	76
	.byte	111
	.byte	99
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	37
	.byte	115
	.byte	10
	.byte	0
l92:
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	32
	.byte	115
	.byte	104
	.byte	111
	.byte	117
	.byte	108
	.byte	100
	.byte	32
	.byte	98
	.byte	101
	.byte	58
	.byte	32
	.byte	32
	.byte	32
	.byte	68
	.byte	72
	.byte	82
	.byte	89
	.byte	83
	.byte	84
	.byte	79
	.byte	78
	.byte	69
	.byte	32
	.byte	80
	.byte	82
	.byte	79
	.byte	71
	.byte	82
	.byte	65
	.byte	77
	.byte	44
	.byte	32
	.byte	50
	.byte	39
	.byte	78
	.byte	68
	.byte	32
	.byte	83
	.byte	84
	.byte	82
	.byte	73
	.byte	78
	.byte	71
	.byte	10
	.byte	0
l93:
	.byte	10
	.byte	0
l94:
	.byte	85
	.byte	115
	.byte	101
	.byte	114
	.byte	32
	.byte	116
	.byte	105
	.byte	109
	.byte	101
	.byte	58
	.byte	32
	.byte	37
	.byte	100
	.byte	10
	.byte	0
	//registers used:
		//r0: yes
		//r1: yes
		//r2: yes
		//r3: yes
		//r4: yes
		//r5: yes
		//r6: yes
		//r7: yes
		//tmp: yes
	.section	.text.0
	.global	_Proc_1
_Proc_1:
	exg	r6
	stmpdec	r6
	stmpdec	r2
	stmpdec	r3
	stmpdec	r4
	stmpdec	r5
	exg	r6
				// allocreg r5
				// allocreg r2

	//dhry_1.c, line 345
					// (a/p assign)
					// (prepobj r1) reg r2 - no need to prep
					// (load_temp - type 10) not varadr
					// (objtotemp) deref 
					// (prepobj tmp) deref  var FIXME - deref? reg 
				// constant: 14 in 1 chunks
	li	IMW0(20)
	addt	r6
	ldt
//marker 1
		//sizemod based on type 0xa
	ldt
//marker 2
					// (save temp) isreg
	mr	r2
				//save_temp done

	//dhry_1.c, line 345
					// (a/p assign)
					// (prepobj r1) reg r5 - no need to prep
					// (load_temp - type 10) not varadr
					// (objtotemp) reg r2
	mt	r2
					// (save temp) isreg
	mr	r5
				//save_temp done

	//dhry_1.c, line 350
					// (a/p assign)
					// (prepobj r1) deref  reg r2 - no need to prep
// Copying 48 bytes to 
					// (load_temp - type 12) not varadr
					// (objtotemp) deref 
					// (prepobj tmp) deref  var FIXME - deref? FIXME - deref?	ldinc	r7
	.int	_Ptr_Glob
		//sizemod based on type 0xc
	ldt
//marker 2
	mr	r0
	mt	r2
	stdec	r6
				// constant: 30 in 2 chunks
	li	IMW1(48)
	li	IMW0(48)
	addt	r1
	mr	r2
.cpyloop4:
	ldbinc	r0
	stbinc	r1
	mt	r1
	cmp	r2
	cond	NEQ
		li	IMW0(PCREL(.cpyloop4))
		add	r7
	ldinc	r6
	mr	r2
				// allocreg r4

	//dhry_1.c, line 351
					// (bitwise) loadreg
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
				// constant: 14 in 1 chunks
	li	IMW0(20)
	ldidx	r6
	mr	r4
					// (objtotemp) const
				// constant: c in 1 chunks
	li	IMW0(12)
	add	r4
					// (save result) isreg

	//dhry_1.c, line 351
					// (a/p assign)
					// (prepobj r1) deref  reg r4 - no need to prep
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 5 in 1 chunks
	li	IMW0(5)
					// (save temp) store reg
	st	r4
				//save_temp done
				// allocreg r3

	//dhry_1.c, line 353
					// (bitwise) loadreg
					// (objtotemp) reg r2
	mt	r2
	mr	r3
					// (objtotemp) const
				// constant: c in 1 chunks
	li	IMW0(12)
	add	r3
					// (save result) isreg

	//dhry_1.c, line 353
					// (a/p assign)
					// (prepobj r1) deref  reg r3 - no need to prep
					// (load_temp - type 3) not varadr
					// (objtotemp) deref 
	ld	r4
					// (save temp) store reg
	st	r3
				//save_temp done
				// freereg r4
				// freereg r3

	//dhry_1.c, line 354
					// (a/p assign)
					// (prepobj r1) deref  reg r2 - no need to prep
					// (load_temp - type 10) not varadr
					// (objtotemp) deref 
					// (prepobj tmp) deref  var FIXME - deref? reg 
				// constant: 14 in 1 chunks
	li	IMW0(20)
	addt	r6
	ldt
//marker 1
		//sizemod based on type 0xa
	ldt
//marker 2
					// (save temp) store reg
	st	r2
				//save_temp done

	//dhry_1.c, line 355
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) reg r2
	mt	r2
	stdec	r6

	//dhry_1.c, line 355
					//call
	ldinc	r7
	.int	_Proc_3
	exg	r7
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r6


	//dhry_1.c, line 358
					// (bitwise) loadreg
					// (objtotemp) const
				// constant: 4 in 1 chunks
	li	IMW0(4)
	add	r2
					// (save result) isreg

	//dhry_1.c, line 358
					// (test)
					// (objtotemp) deref 
	ld	r2
	and	r2
				// freereg r2

	//dhry_1.c, line 358
	cond	NEQ
					//conditional branch 			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l114)-1)
	li	IMW0(PCREL(l114))
		add	r7
				// allocreg r3

	//dhry_1.c, line 361
					// (bitwise) loadreg
					// (objtotemp) reg r5
	mt	r5
	mr	r3
					// (objtotemp) const
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r3
					// (save result) isreg
				// allocreg r2

	//dhry_1.c, line 361
					// (bitwise) loadreg
					// (objtotemp) reg r5
	mt	r5
	mr	r2
					// (objtotemp) const
				// constant: c in 1 chunks
	li	IMW0(12)
	add	r2
					// (save result) isreg

	//dhry_1.c, line 361
					// (a/p assign)
					// (prepobj r1) deref  reg r2 - no need to prep
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 6 in 1 chunks
	li	IMW0(6)
					// (save temp) store reg
	st	r2
				//save_temp done

	//dhry_1.c, line 363
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) reg r3
	mt	r3
	stdec	r6
				// freereg r3
				// allocreg r3

	//dhry_1.c, line 363
					// (bitwise) loadreg
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
				// constant: 18 in 1 chunks
	li	IMW0(24)
	ldidx	r6
	mr	r3
					// (objtotemp) const
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r3
					// (save result) isreg

	//dhry_1.c, line 363
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp) deref 
	ld	r3
	stdec	r6
				// freereg r3

	//dhry_1.c, line 363
					//call
	ldinc	r7
	.int	_Proc_6
	exg	r7
				// constant: 8 in 1 chunks
	li	IMW0(8)
	add	r6


	//dhry_1.c, line 364
					// (a/p assign)
					// (prepobj r1) deref  reg r5 - no need to prep
					// (load_temp - type 10) not varadr
					// (objtotemp) deref 
					// (prepobj tmp) deref  var FIXME - deref? FIXME - deref?	ldinc	r7
	.int	_Ptr_Glob
		//sizemod based on type 0xa
	ldt
//marker 2
					// (save temp) store reg
	st	r5
				//save_temp done

	//dhry_1.c, line 366
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) reg r2
	mt	r2
	stdec	r6

	//dhry_1.c, line 366
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp) const
				// constant: a in 1 chunks
	li	IMW0(10)
	stdec	r6

	//dhry_1.c, line 366
					// (a/p push)
					// a: pushed 8, regnames[sp] r6
					// (objtotemp) deref 
	ld	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 366
					//call
	ldinc	r7
	.int	_Proc_7
	exg	r7
				// constant: c in 1 chunks
	li	IMW0(12)
	add	r6


	//dhry_1.c, line 369
			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l115)-1)
	li	IMW0(PCREL(l115))
	add	r7
l114: # 
				// allocreg r2

	//dhry_1.c, line 369
					// (a/p assign)
					// (prepobj r1) reg r2 - no need to prep
					// (load_temp - type 10) not varadr
					// (objtotemp) deref 
					// (prepobj tmp) deref  var FIXME - deref? reg 
				// constant: 14 in 1 chunks
	li	IMW0(20)
	addt	r6
	ldt
//marker 1
		//sizemod based on type 0xa
	ldt
//marker 2
					// (save temp) isreg
	mr	r2
				//save_temp done

	//dhry_1.c, line 369
					// (a/p assign)
					// (prepobj r1) deref  var FIXME - deref? reg 
				// constant: 14 in 1 chunks
	li	IMW0(20)
	addt	r6
	ldt
//marker 1
	mr	r1
// Copying 48 bytes to Ptr_Val_Par
					// (load_temp - type 12) not varadr
					// (objtotemp) deref 
//FIXME - unhandled type 12
	mr	r0
	mt	r2
	stdec	r6
				// constant: 30 in 2 chunks
	li	IMW1(48)
	li	IMW0(48)
	addt	r1
	mr	r2
.cpyPtr_Val_Parloop5:
	ldbinc	r0
	stbinc	r1
	mt	r1
	cmp	r2
	cond	NEQ
		li	IMW0(PCREL(.cpyPtr_Val_Parloop5))
		add	r7
	ldinc	r6
	mr	r2
				// freereg r2
l115: # 
				// freereg r5
	ldinc	r6
	mr	r5
	ldinc	r6
	mr	r4
	ldinc	r6
	mr	r3
	ldinc	r6
	mr	r2
	ldinc	r6
	mr	r7

// stacksize=0+??
	//registers used:
		//r0: yes
		//r1: yes
		//r2: yes
		//r3: yes
		//r4: no
		//r5: no
		//r6: yes
		//r7: yes
		//tmp: yes
	.section	.text.0
	.global	_Proc_2
_Proc_2:
	exg	r6
	stmpdec	r6
	stmpdec	r2
	stmpdec	r3
	exg	r6
	stdec	r6	// quickest way to decrement sp by 4
				// allocreg r3

	//dhry_1.c, line 383
					// (bitwise) loadreg
					// (objtotemp) deref 
					// (prepobj tmp) deref  var FIXME - deref? reg 
				// constant: 10 in 1 chunks
	li	IMW0(16)
	addt	r6
	ldt
//marker 1
		//sizemod based on type 0x3
	ldt
//marker 2
	mr	r3
					// (objtotemp) const
				// constant: a in 1 chunks
	li	IMW0(10)
	add	r3
					// (save result) isreg
l122: # 
				// allocreg r2

	//dhry_1.c, line 385
					//FIXME convert
					// (load_temp - type 1) not varadr
					// (objtotemp) extern
	ldinc	r7
	.int	_Ch_1_Glob
	byt
	ldt
	mr	r2
	li	24
	shl	r2
	sgn
	shr	r2
					// (save result) isreg

	//dhry_1.c, line 385
					// (compare) (q1 signed) (q2 signed)					// (objtotemp) reg r2
	mt	r2
	mr	r1
					// (objtotemp) const
				// constant: 41 in 2 chunks
	li	IMW1(65)
	li	IMW0(65)
	sgn
	cmp	r1
				// freereg r2

	//dhry_1.c, line 385
	cond	NEQ
					//conditional branch 			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l121)-1)
	li	IMW0(PCREL(l121))
		add	r7

	//dhry_1.c, line 388
					// (bitwise) loadreg
					// (objtotemp) const
				// constant: 1 in 1 chunks
	li	IMW0(1)
	sub	r3
					// (save result) isreg

	//dhry_1.c, line 389
					// (bitwise) loadreg
					// (objtotemp) reg r3
	mt	r3
	mr	r0
					// (objtotemp) extern
	ldinc	r7
	.int	_Int_Glob
	ldt//marker 3
	sub	r0
					// (save result) deref
					// (load_temp - type 10) not varadr
					// (objtotemp) var, auto|reg
		//sizemod based on type 0xa
				// constant: 10 in 1 chunks
	li	IMW0(16)
	ldidx	r6
	mr	r1
				// store reg
// Store_reg to type 0x3
					// (prepobj tmp) deref 	mt	r1
	stmpdec	r0

	//dhry_1.c, line 390
					// (a/p assign)
					// (prepobj r1) var, auto|reg
	mt	r6
	mr	r1
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 0 in 1 chunks
	li	IMW0(0)
					// (save temp) store prepped reg
	st	r1
				//save_temp done
l121: # 

	//dhry_1.c, line 392
					// (test)
					// (objtotemp) var, auto|reg
		//sizemod based on type 0x3
	ld	r6

	//dhry_1.c, line 392
	cond	NEQ
					//conditional branch 			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l122)-1)
	li	IMW0(PCREL(l122))
		add	r7
				// freereg r3
	ldinc	r6	// quickest way to add 4 to sp
	ldinc	r6
	mr	r3
	ldinc	r6
	mr	r2
	ldinc	r6
	mr	r7

// stacksize=0+??
	//registers used:
		//r0: yes
		//r1: yes
		//r2: yes
		//r3: no
		//r4: no
		//r5: no
		//r6: yes
		//r7: yes
		//tmp: yes
	.section	.text.0
	.global	_Proc_3
_Proc_3:
	stdec	r6
	mt	r2
	stdec	r6

	//dhry_1.c, line 404
					// (test)
					// (objtotemp) extern
	ldinc	r7
	.int	_Ptr_Glob
	ldt//marker 3

	//dhry_1.c, line 404
	cond	EQ
					//conditional branch 			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l126)-1)
	li	IMW0(PCREL(l126))
		add	r7

	//dhry_1.c, line 406
					// (a/p assign)
					// (prepobj r1) deref  var FIXME - deref? reg 
				// constant: 8 in 1 chunks
	li	IMW0(8)
	addt	r6
	ldt
//marker 1
	mr	r1
					// (load_temp - type 10) not varadr
					// (objtotemp) deref 
					// (prepobj tmp) deref  var FIXME - deref? FIXME - deref?	ldinc	r7
	.int	_Ptr_Glob
		//sizemod based on type 0xa
	ldt
//marker 2
					// (save temp) store prepped reg
	st	r1
				//save_temp done
l126: # 
				// allocreg r2

	//dhry_1.c, line 407
					// (bitwise) loadreg
					// (objtotemp) extern
	ldinc	r7
	.int	_Ptr_Glob
	ldt//marker 3
	mr	r2
					// (objtotemp) const
				// constant: c in 1 chunks
	li	IMW0(12)
	add	r2
					// (save result) isreg

	//dhry_1.c, line 407
					// (a/p push)
					// a: pushed 0, regnames[sp] r6
					// (objtotemp) reg r2
	mt	r2
	stdec	r6
				// freereg r2

	//dhry_1.c, line 407
					// (a/p push)
					// a: pushed 4, regnames[sp] r6
					// (objtotemp) extern
	ldinc	r7
	.int	_Int_Glob
	ldt//marker 3
	stdec	r6

	//dhry_1.c, line 407
					// (a/p push)
					// a: pushed 8, regnames[sp] r6
					// (objtotemp) const
				// constant: a in 1 chunks
	li	IMW0(10)
	stdec	r6

	//dhry_1.c, line 407
					//call
	ldinc	r7
	.int	_Proc_7
	exg	r7
				// constant: c in 1 chunks
	li	IMW0(12)
	add	r6

	ldinc	r6
	mr	r2
	ldinc	r6
	mr	r7

// stacksize=0+??
	//registers used:
		//r0: yes
		//r1: yes
		//r2: yes
		//r3: no
		//r4: no
		//r5: no
		//r6: yes
		//r7: yes
		//tmp: yes
	.section	.text.0
	.global	_Proc_4
_Proc_4:
	stdec	r6
	mt	r2
	stdec	r6
				// allocreg r2

	//dhry_1.c, line 417
					//FIXME convert
					// (load_temp - type 1) not varadr
					// (objtotemp) extern
	ldinc	r7
	.int	_Ch_1_Glob
	byt
	ldt
	mr	r2
	li	24
	shl	r2
	sgn
	shr	r2
					// (save result) isreg

	//dhry_1.c, line 417
					// (compare) (q1 signed) (q2 signed)					// (objtotemp) reg r2
	mt	r2
	mr	r1
					// (objtotemp) const
				// constant: 41 in 2 chunks
	li	IMW1(65)
	li	IMW0(65)
	sgn
	cmp	r1
				// freereg r2

	//dhry_1.c, line 417
	cond	EQ
					//conditional branch 			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l128)-1)
	li	IMW0(PCREL(l128))
		add	r7
				// allocreg r2

	//dhry_1.c, line 417
					// (a/p assign)
					// (prepobj r1) reg r2 - no need to prep
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 0 in 1 chunks
	li	IMW0(0)
					// (save temp) isreg
	mr	r2
				//save_temp done

	//dhry_1.c, line 417
			//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.
	li	IMW1(PCREL(l129)-1)
	li	IMW0(PCREL(l129))
	add	r7
l128: # 

	//dhry_1.c, line 417
					// (a/p assign)
					// (prepobj r1) reg r2 - no need to prep
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 1 in 1 chunks
	li	IMW0(1)
					// (save temp) isreg
	mr	r2
				//save_temp done
l129: # 

	//dhry_1.c, line 418
					// (bitwise) loadreg
					// (objtotemp) extern
	ldinc	r7
	.int	_Bool_Glob
	ldt//marker 3
	mr	r0
					// (objtotemp) reg r2
	mt	r2
	or	r0
					// (save result) store reg
// Store_reg to type 0x3
					// (prepobj tmp) extern (offset 0)
	ldinc	r7
	.int	_Bool_Glob
	stmpdec	r0

	//dhry_1.c, line 419
					// (a/p assign)
					// (prepobj r1) extern (offset 0)
	ldinc	r7
	.int	_Ch_2_Glob
	mr	r1
					// (load_temp - type 1) not varadr
					// (objtotemp) const
				// constant: 42 in 2 chunks
	li	IMW1(66)
	li	IMW0(66)
					// (save temp) store prepped reg
	stbinc	r1
//Disposable, postinc doesn't matter
				//save_temp done
				// freereg r2
	ldinc	r6
	mr	r2
	ldinc	r6
	mr	r7

// stacksize=0+??
	//registers used:
		//r0: yes
		//r1: yes
		//r2: no
		//r3: no
		//r4: no
		//r5: no
		//r6: yes
		//r7: yes
		//tmp: yes
	.section	.text.0
	.global	_Proc_5
_Proc_5:
	stdec	r6

	//dhry_1.c, line 427
					// (a/p assign)
					// (prepobj r1) extern (offset 0)
	ldinc	r7
	.int	_Ch_1_Glob
	mr	r1
					// (load_temp - type 1) not varadr
					// (objtotemp) const
				// constant: 41 in 2 chunks
	li	IMW1(65)
	li	IMW0(65)
					// (save temp) store prepped reg
	stbinc	r1
//Disposable, postinc doesn't matter
				//save_temp done

	//dhry_1.c, line 428
					// (a/p assign)
					// (prepobj r1) extern (offset 0)
	ldinc	r7
	.int	_Bool_Glob
	mr	r1
					// (load_temp - type 3) not varadr
					// (objtotemp) const
				// constant: 0 in 1 chunks
	li	IMW0(0)
					// (save temp) store prepped reg
	st	r1
				//save_temp done
	ldinc	r6
	mr	r7

// stacksize=0+??
	.globl	_Reg
	.section	.data
	.align	2
_Reg:
	.int	0
	.globl	_Number_Of_Runs
	.align	2
_Number_Of_Runs:
	.int	1
	.globl	_Ptr_Glob
	.section	.bss
	.global	_Ptr_Glob
	.comm	_Ptr_Glob,4
	.globl	_Next_Ptr_Glob
	.global	_Next_Ptr_Glob
	.comm	_Next_Ptr_Glob,4
	.globl	_Int_Glob
	.global	_Int_Glob
	.comm	_Int_Glob,4
	.globl	_Bool_Glob
	.global	_Bool_Glob
	.comm	_Bool_Glob,4
	.globl	_Arr_1_Glob
	.global	_Arr_1_Glob
	.comm	_Arr_1_Glob,200
	.globl	_Arr_2_Glob
	.global	_Arr_2_Glob
	.comm	_Arr_2_Glob,10000
	.globl	_Begin_Time
	.global	_Begin_Time
	.comm	_Begin_Time,4
	.globl	_End_Time
	.global	_End_Time
	.comm	_End_Time,4
	.globl	_User_Time
	.global	_User_Time
	.comm	_User_Time,4
	.globl	_Microseconds
	.global	_Microseconds
	.comm	_Microseconds,4
	.globl	_Dhrystones_Per_Second
	.global	_Dhrystones_Per_Second
	.comm	_Dhrystones_Per_Second,4
	.globl	_Vax_Mips
	.global	_Vax_Mips
	.comm	_Vax_Mips,4
	.globl	_rec1
	.global	_rec1
	.comm	_rec1,48
	.globl	_rec2
	.global	_rec2
	.comm	_rec2,48
	.globl	_strcpy
	.globl	_small_printf
	.globl	_Ch_1_Glob
	.global	_Ch_1_Glob
	.comm	_Ch_1_Glob,1
	.globl	_Ch_2_Glob
	.global	_Ch_2_Glob
	.comm	_Ch_2_Glob,1
	.globl	_Func_1
	.globl	_Str_1_Loc
	.global	_Str_1_Loc
	.comm	_Str_1_Loc,31
	.globl	_Str_2_Loc
	.global	_Str_2_Loc
	.comm	_Str_2_Loc,31
	.globl	_puts
	.globl	_Func_2
	.globl	_Proc_7
	.globl	_Proc_8
	.globl	_Proc_6
