#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "832util.h"
#include "symbol.h"

struct symbol *symbol_new(const char *id,int cursor,int flags)
{
	struct symbol *result;
	if(result=(struct symbol *)malloc(sizeof(struct symbol)))
	{
		result->next=0;
		result->identifier=strdup(id);
		result->cursor=cursor;
		result->flags=flags;
	}
	return(result);
}

void symbol_delete(struct symbol *sym)
{
	if(sym)
	{
		if(sym->identifier)
			free(sym->identifier);
		free(sym);
	}
}


int symbol_matchname(struct symbol *sym,const char *name)
{
	if(sym && name)
		return(strcmp(sym->identifier,name)==0);
	return(0);
}


void symbol_output(struct symbol *sym,FILE *f)
{
	if(sym)
	{
		fputc(sym->align,f);
		fputc(sym->flags,f);
		write_int_le(sym->cursor,f);
		write_lstr(sym->identifier,f);
	}
}


void symbol_dump(struct symbol *sym)
{
	if(sym)
		printf("%s, cursor: %d, flags: %x, align: %d\n",sym->identifier, sym->cursor,sym->flags,sym->align);
}

