#ifndef SYMBOL_H
#define SYMBOL_H

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

struct symbol *symbol_new(const char *id,int cursor,int flags);
void symbol_delete(struct symbol *sym);

int symbol_matchname(struct symbol *sym,const char *name);

void symbol_dump(struct symbol *sym);

#endif

