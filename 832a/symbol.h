#ifndef SYMBOL_H
#define SYMBOL_H

#include "section.h"

#define SYMBOLFLAG_ABS 1
#define SYMBOLFLAG_PCREL 2
#define SYMBOLFLAG_GLOBAL 4
#define SYMBOLFLAG_LOCAL 8
#define SYMBOLFLAG_EXTERN 16
#define SYMBOLFLAG_WEAK 32
#define SYMBOLFLAG_ABSOLUTE 64

struct symbol
{
	struct symbol *next;
	char *identifier;
	int align;
	int cursor;
	int flags;
	/* Used by linker */
	struct symbol *resolve;
	struct section *sect;
};

struct symbol *symbol_new(const char *id,int cursor,int flags);
void symbol_delete(struct symbol *sym);

int symbol_matchname(struct symbol *sym,const char *name);

void symbol_output(struct symbol *sym,FILE *f);

void symbol_dump(struct symbol *sym);

#endif

