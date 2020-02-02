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
		result->align=0;
		result->sect=0;
		result->resolve=0;
		result->address_worstcase=0;
		result->address_bestcase=0;
		result->size_worstcase=0;
		result->size_bestcase=0;
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

static int count_pcrelchunks(unsigned int a1,unsigned int a2)
{
	int i;
	printf("Counting displacement from %d to %d\n",a1,a2);
	for(i=1;i<6;++i)
	{
		unsigned int d=a2-(a1+i);
		d&=0xffffffff;
		if(i>=count_constantchunks(d))
			return(i);
	}
	return(6);
}

void reference_size(struct symbol *sym)
{
	if(sym)
	{
		if(sym->flags&SYMBOLFLAG_ALIGN)
		{
		/* The best-case size for an alignment will be calculated at the same time as
		   object addresses */
		/*	sym->size_bestcase=0;	 */
	
			sym->size_worstcase=sym->align-1;
		}
		else if(sym->flags&SYMBOLFLAG_REFERENCE)
		{
			/* simple references are always four bytes */
			sym->size_bestcase=4;
			sym->size_worstcase=4;
		}
		else if (sym->flags&SYMBOLFLAG_LDABS)
		{
			if(sym->resolve)
			{
				if(sym->resolve->address_bestcase)
				{
					/* Compute best- and worst-case sizes based on the absolute address of the target. */
					sym->size_bestcase=count_constantchunks(sym->resolve->address_bestcase);
					sym->size_worstcase=count_constantchunks(sym->resolve->address_worstcase);
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
					int i;
					int reladr;
					int best=sym->sect->address_bestcase+sym->cursor;
					int worst=sym->sect->address_worstcase+sym->cursor;
					printf("Reference %s, cursor %d, best %d, worst %d\n",sym->identifier,sym->cursor,best,worst);
					sym->size_bestcase=count_pcrelchunks(best,sym->resolve->address_bestcase);
					sym->size_worstcase=count_pcrelchunks(worst,sym->resolve->address_worstcase);
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
		printf("size (best case) %d, size (worst case) %d\n",sym->size_bestcase, sym->size_worstcase);
		printf("    address (best case) %d, size (worst case) %d\n",sym->address_bestcase, sym->address_worstcase);
	}
}

