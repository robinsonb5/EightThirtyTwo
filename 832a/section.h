#ifndef SECTION_H
#define SECTION_H

#include "codebuffer.h"
#include "symbol.h"

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

struct section *section_new(const char *name);
void section_delete(struct section *sect);

/* Section names are case-sensitive */
int section_matchname(struct section *sect,const char *name);

struct symbol *section_findsymbol(struct section *sect,const char *symname);
void section_emitbyte(struct section *sect,unsigned char byte);

void section_dump(struct section *sect);

#endif

