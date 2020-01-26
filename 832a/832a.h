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

void error_setfile(const char *fn);
void error_setline(int line);
void asmerror(const char *err);

#endif

