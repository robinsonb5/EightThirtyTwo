#define IMW0(x) ((x)&0x3f)
#define IMW1(x) (((x)>>6)&0x3f)
#define IMW2(x) (((x)>>12)&0x3f)
#define IMW3(x) (((x)>>18)&0x3f)
#define IMW4(x) (((x)>>24)&0x3f)
#define IMW5(x) (((x)>>30)&0x3)

#define PCREL(x) ((x-.)-2)

#define cond .byte 0x00 +
#define exg .byte 0x08 +
#define ldbinc .byte 0x10 +
#define stdec .byte 0x18 +

#define ldinc .byte 0x20 +
#define shr .byte 0x28 +
#define shl .byte 0x30 +
#define ror .byte 0x38 +

#define sth .byte 0x40 +
#define mr .byte 0x48 +
#define stbinc .byte 0x50 +
#define stmpdec .byte 0x58 +

#define ldidx .byte 0x60 +
#define ld .byte 0x68 +
#define mt .byte 0x70 +
#define st .byte 0x78 +

#define add .byte 0x80 +
// Add's behaviour is different for r7 - perhaps use a different mnemonic?
#define sub .byte 0x88 +
#define mul .byte 0x90 +
#define and .byte 0x98 +

#define addt .byte 0xa0 +
#define cmp .byte 0xa8 +
#define or .byte 0xb0 +
#define xor .byte 0xb8 +

#define li .byte 0xc0 +

// Overloaded opcodes.  Mostly ops that make no sense when applied to R7

#define ldt .byte 0xbf	// Overloads xor
#define	sgn .byte 0xb7	// Overloads or
#define hlf	.byte 0x9f  // Overloads and

#define r0 0
#define r1 1
#define r2 2
#define r3 3
#define r4 4
#define r5 5
#define r6 6
#define r7 7

#define NEX 0	// Match none.
#define SGT 1	// Zero clear, carry clear
#define EQ 2	// Zero set, carry don't care
#define GE 3	// Zero set or carry clear
#define SLT 4	// Zero clear, carry set
#define NEQ 5	// Zero clear, carry don't care
#define LE 6	// Zero set or carry set
#define EX 7	// Zero don't care, carry don't care

