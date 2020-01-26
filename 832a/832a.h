#ifndef EIGHTTHIRTYTWOASSEMBLER_H
#define EIGHTTHIRTYTWOASSEMBLER_H

struct opcode
{
	const char *mnem;
	int opcode;
	int opbits;
};

struct opcode operands[17];
struct opcode opcodes[30];

#endif

