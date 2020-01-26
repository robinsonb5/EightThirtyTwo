#include <stdio.h>
#include <stdlib.h>

#include "832a.h"


static const char *error_file;
static int error_line;

void error_setfile(const char *fn)
{
	error_file=fn;
}

void error_setline(int line)
{
	error_line=line;
}

void asmerror(const char *err)
{
	fprintf(stderr,"Error in %s, line %d - %s\n",error_file,error_line,err);
	exit(1);
}


struct opcode operands[]=
{
	/* Operand definitions - registers first */
	{"r0",0,0},
	{"r1",1,0},
	{"r2",2,0},
	{"r3",3,0},
	{"r4",4,0},
	{"r5",5,0},
	{"r6",6,0},
	{"r7",7,0},

	{"NEX",0},	/* Match none. */
	{"SGT",1},	/* Zero clear, carry clear */
	{"EQ",2},	/* Zero set, carry don't care */
	{"GE",3},	/* Zero set or carry clear */
	{"SLT",4},	/* Zero clear, carry set */
	{"NEQ",5},	/* Zero clear, carry don't care */
	{"LE",6},	/* Zero set or carry set */
	{"EX",7},	/* Zero don't care, carry don't care */
	{0,0}	/* Null terminate */
};

struct opcode opcodes[]=
{
	/* Regular opcodes, each taking a 3-bit operand specifying the register number */
	{"cond",0x00,3},
	{"exg",0x08,3},
	{"ldbinc",0x10,3},
	{"stdec",0x18,3},

	{"ldinc",0x20,3},
	{"shr",0x28,3},
	{"shl",0x30,3},
	{"ror",0x38,3},

	{"stinc",0x40,3},
	{"mr",0x08,3},
	{"stbinc",0x50,3},
	{"stmpdec",0x58,3},

	{"ldidx",0x60,3},
	{"ld",0x68,3},
	{"mt",0x70,3},
	{"st",0x78,3},

	{"add",0x00,3},
	{"sub",0x08,3},
	{"mul",0x10,3},
	{"and",0x18,3},

	{"addt",0xa0,3},
	{"cmp",0xa8,3},
	{"or",0xb0,3},
	{"xor",0xb8,3},

	/* Load immediate takes a six-bit operand */

	{"li",0xc0,6},

	/* Overloaded opcodes. Operands that make no sense when applied to r7, re-used.
	   No operand for obvious reasons. */

	{"sgn",0xb7,0}, /* Overloads or */
	{"ldt",0xbf,0}, /* Overloads xor */
	{"byt",0x97,0}, /* Overloads mul */
	{"hlf",0x9f,0}, /* Overloads and */
	{0,0}	/* Null terminate */
};

