#ifndef EIGHTTHIRTYTWOASSEMBLER_H
#define EIGHTTHIRTYTWOASSEMBLER_H

#define CODEBUFFERSIZE 1024

struct codebuffer
{
	struct codebuffer *next;
	char *buf;
	int size;
};


#define SYMBOLFLAG_ABS 1
#define SYMBOLFLAG_PCREL 2
#define SYMBOLFLAG_EXTERN 4
#define SYMBOLFLAG_LOCAL 8
#define SYMBOLFLAG_WEAK 16

struct symbol
{
	struct symbol *next;
	char *identifier;
	int cursor;
	int flags;
};


struct section
{
	struct section *next;
	char *identifier;
	int address;
	int cursor;
	struct codebuffer *codebuffers;
	struct codebuffer *lastcodebuffer;
	struct symbol *symbols;
	struct symbol *lastsymbol;
	struct symbol *relocations;
	struct symbol *lastreloc;
};


struct program
{
	struct section *sections;
	struct section *lastsection;
}


struct opcode
{
	const char *mnem;
	int opcode;
	int opbits;
};

struct opcode operands[17];
struct opcode opcodes[30];

#endif

