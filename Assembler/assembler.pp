#define IMW0(x) ((x)&0x3f)
#define IMW1(x) (((x)>>6)&0x3f)
#define IMW2(x) (((x)>>12)&0x3f)
#define IMW3(x) (((x)>>18)&0x3f)
#define IMW4(x) (((x)>>24)&0x3f)
#define IMW5(x) (((x)>>30)&0x3)

#define PCREL(x) ((x-.)-2)

#define cond .byte 0x00 +
 
#define mr .byte 0x08 +
#define sub .byte 0x10 +
#define cmp .byte 0x18 +
#define st .byte 0x20 +
#define stdec .byte 0x28 +
#define stx .byte 0x30 +
#define stbinc .byte 0x38 +
 
#define and .byte 0x40 +
#define or .byte 0x48 +
#define xor .byte 0x50 +
#define shl .byte 0x58 +
#define asr .byte 0x60 +
#define lsr .byte 0x68 +
#define ror .byte 0x70 +
#define rorc .byte 0x78 +
 
#define exg .byte 0x80 +
#define mt .byte 0x88 +
#define add .byte 0x90 +
#define addt .byte 0x98 +
#define ld .byte 0xa0 +
#define ldinc .byte 0xa8 +
#define ldx .byte 0xb0 +
#define ldbinc .byte 0xb8 +
#define li .byte 0xc0 +

#if 0 // old encoding
#define cond .byte 0x0 +
#define mt .byte 0x08 +
#define mr .byte 0x10 +
#define exg .byte 0x18 +
#define ldi .byte 0x20 +
#define st .byte 0x28 +
#define ld .byte 0x30 +
#define sti .byte 0x38 +
#define add .byte 0x40 +
#define cmp .byte 0x48 +
#define ldinc .byte 0x50 +
#define sub .byte 0x58 +
#define stdec .byte 0x60 +
#define and .byte 0x68 +
#define or .byte 0x70 +
#define xor .byte 0x78 +
#define addt .byte 0x80 +
#define shl .byte 0x88 +
#define asr .byte 0x90 +
#define lsr .byte 0x98 +
#define ror .byte 0xa0 +
#define rorc .byte 0xa8 +
#define stbinc .byte 0xb0 +
#define ldbinc .byte 0xb8 +
#define li .byte 0xc0 +
#endif 

#define r0 0
#define r1 1
#define r2 2
#define r3 3
#define r4 4
#define r5 5
#define r6 6
#define r7 7

#define NEX 0
#define SGT 1
#define EQ 2
#define GE 3
#define SLT 4
#define NEQ 5
#define LE 6
#define EX 7

