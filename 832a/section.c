#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "832a.h"
#include "section.h"

struct section *section_new(const char *name)
{
	struct section *sect;
	sect=(struct section *)malloc(sizeof(struct section));
	if(sect)
	{
		sect->next=0;
		sect->identifier=strdup(name);
		sect->symbols=0;
		sect->lastsymbol=0;
		sect->codebuffers=0;
		sect->relocations=0;
		sect->lastreloc=0;
		sect->address=0;
		sect->cursor=0;
	}
	return(sect);
}


int section_matchname(struct section *sect,const char *name)
{
	if(sect && name)
		return(strcmp(sect->identifier,name)==0);
	return(0);
}


void section_delete(struct section *sect)
{
	if(sect)
	{
		if(sect->identifier)
			free(sect->identifier);
		free(sect);
	}
}


struct symbol *section_findsymbol(struct section *sect,const char *symname)
{
	if(!sect)
		return(0);
	struct symbol *sym=sect->symbols;
	while(sym)
	{
		if(symbol_matchname(sym,symname))
			return(sym);
		sym=sym->next;
	}
	return(0);
}


void section_addsymbol(struct section *sect, const char *name)
{
	struct symbol *sym;
	if(sect && name)
	{
		sym=section_findsymbol(sect,name);
		if(sym)
		{
			if(sym->cursor!=-1)
				asmerror("Symbol redefined\n");
			else
				sym->cursor=sect->cursor;
		}
		else
		{
			sym=symbol_new(name,sect->cursor,0);
			if(sect->lastsymbol)
				sect->lastsymbol->next=sym;
			else
				sect->symbols=sym;
			sect->lastsymbol=sym;
		}
	}
}


void section_emitbyte(struct section *sect,unsigned char byte)
{
	if(sect)
	{
		/* Write a byte to the buffer here. */
		++sect->cursor;
	}
}



void section_dump(struct section *sect)
{
	if(sect)
	{
		struct symbol *sym;
		printf("\nSection: %s\n",sect->identifier);
		printf("  address: %x, cursor: %x\n",sect->address, sect->cursor);

		printf("\nSymbols:\n");
		sym=sect->symbols;
		while(sym)
		{
			symbol_dump(sym);
			sym=sym->next;
		}

		printf("\nRelocations:\n");
		sym=sect->relocations;
		while(sym)
		{
			symbol_dump(sym);
			sym=sym->next;
		}
	}
}

