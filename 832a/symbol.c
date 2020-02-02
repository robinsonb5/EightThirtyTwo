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


/* Calculate the best- and worst-case size for a reference.
   The only variable-size reference types are LDABS, LDPCREL and ALIGN
 */

void reference_size(struct symbol *sym,int address_bestcase, int address_worstcase)
{
	if(sym)
	{
		if(sym->flags&SYMBOLFLAG_ALIGN)
		{
			sym->size_bestcase=0;
			sym->size_worstcase=sym->align-1;
		}
		else if(sym->flags&SYMBOLFLAG_REFERENCE)
		{
			/* simply references are always four bytes */
			sym->size_bestcase=4;
			sym->size_worstcase=4;
		}
		else if (sym->flags&SYMBOLFLAG_LDABS)
		{
			if(sym->resolve)
			{
				if(sym->resolve->address_bestcase)
				{
					/* Compute best- and worst-case sizes based on the distance to the target. */
				}
				else
				{
					sym->size_bestcase=1;
					sym->size_worstcase=6;
				}
			}
		}
		else if (sym->flags&SYMBOLFLAG_LDPCREL)
		{
			if(sym->resolve)
			{
				if(sym->resolve->address_bestcase)
				{
					/* Compute best- and worst-case sizes based on the distance to the target. */
				}
				else
				{
					sym->size_bestcase=1;
					sym->size_worstcase=6;
				}
			}
		}
	}
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
	{
		printf("%s, cursor: %d, flags: %x, align: %d\n",sym->identifier, sym->cursor,sym->flags,sym->align);
		printf("    resolves to %x, ",(int)sym->resolve);
		printf("size (best case) %d, size (worst case) %d\n",sym->size_bestcase, sym->size_worstcase);
		printf("    address (best case) %d, size (worst case) %d\n",sym->address_bestcase, sym->address_worstcase);
	}
}

