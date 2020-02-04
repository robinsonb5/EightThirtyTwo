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
		result->offset=0;
		result->sect=0;
		result->resolve=0;
		result->address=0;
		result->size=0;
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


/* Calculate the worst-case size for a reference.
   The only variable-size reference types are LDABS, LDPCREL and ALIGN
 */

static int count_pcrelchunks(unsigned int a1,unsigned int a2)
{
	int i;
	printf("Counting displacement from %x to %x\n",a1,a2);
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
			/* Use the worst-case size initially */
			sym->size=sym->offset-1;
		}
		else if(sym->flags&SYMBOLFLAG_REFERENCE)
		{
			/* simple references are always four bytes */
			sym->size=4;
		}
		else if (sym->flags&SYMBOLFLAG_LDABS)
		{
			if(sym->resolve)
			{
				if(sym->resolve->address)
				{
					/* Compute sizes based on the absolute address of the target. */
					sym->size=count_constantchunks(sym->resolve->address+sym->offset);
				}
				else
				{
					/* Worst case size */
					sym->size=6;
				}
			}
		}
		else if (sym->flags&SYMBOLFLAG_LDPCREL)
		{
			if(sym->resolve)
			{
				if(sym->resolve->address)
				{
					int i;
					int reladr;
					int addr=sym->sect->address+sym->cursor+sym->sect->offset+1;
					/* Compute worst-case sizes based on the distance to the target. */
					printf("Reference %s, cursor %x, address %x\n",sym->identifier,sym->cursor,addr);
					sym->size=count_pcrelchunks(addr,sym->resolve->address+sym->offset);
				}
				else
				{
					/* Worst case size */
					sym->size=6;
				}
			}
		}
	}
}


void symbol_output(struct symbol *sym,FILE *f)
{
	if(sym)
	{
		fputc(sym->offset,f);
		fputc(sym->flags,f);
		write_int_le(sym->cursor,f);
		write_lstr(sym->identifier,f);
	}
}


void symbol_dump(struct symbol *sym)
{
	if(sym)
	{
		printf("%s, cursor: %d, flags: %x, offset: %d\n",sym->identifier, sym->cursor,sym->flags,sym->offset);
		printf("size %d, address %x\n",sym->size,sym->address);
	}
}

