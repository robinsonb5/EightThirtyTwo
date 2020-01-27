#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "832util.h"
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
		sect->lastcodebuffer=0;
		sect->refs=0;
		sect->lastref=0;
		sect->address=0;
		sect->cursor=0;
		sect->align=0;
		sect->bss=0;
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
		struct symbol *sym,*nextsym;
		struct codebuffer *buf,*nextbuf;

		if(sect->identifier)
			free(sect->identifier);

		nextsym=sect->symbols;
		while(nextsym)
		{
			sym=nextsym;
			nextsym=sym->next;
			symbol_delete(sym);
		}

		nextsym=sect->refs;
		while(nextsym)
		{
			sym=nextsym;
			nextsym=sym->next;
			symbol_delete(sym);
		}

		nextbuf=sect->codebuffers;
		while(nextbuf)
		{
			buf=nextbuf;
			nextbuf=buf->next;
			codebuffer_delete(buf);
		}

		free(sect);
	}
}


void section_addsymbol(struct section *sect, struct symbol *sym)
{
	if(sect->lastsymbol)
		sect->lastsymbol->next=sym;
	else
		sect->symbols=sym;
	sect->lastsymbol=sym;
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


/*	Hunts for an existing symbol; creates it if not found,
	with a cursor position of -1 to indicate that it's not
    been declared, only referenced.  */

struct symbol *section_getsymbol(struct section *sect, const char *name)
{
	struct symbol *sym;
	if(sect && name)
	{
		if(!(sym=section_findsymbol(sect,name)))
		{
			sym=symbol_new(name,-1,0);
			if(sect->lastsymbol)
				sect->lastsymbol->next=sym;
			else
				sect->symbols=sym;
			sect->lastsymbol=sym;
		}
		return(sym);
	}
}


/*	Hunts for an existing symbol; if it has been referenced but not
	declared, declares it, otherwise creates a new symbol.
	If it's been declared already throw an error.
	The most recently specified alignment is applied to the new symbol
	and the section's alignment value is cleared. */
 
void section_declaresymbol(struct section *sect, const char *name,int flags)
{
	struct symbol *sym;
	if(sect && name)
	{
		sym=section_getsymbol(sect,name);
		if(sym)
		{
			if(sym->cursor!=-1)
				asmerror("Symbol redefined\n");
			else
			{
				sym->flags|=flags;
				sym->cursor=sect->cursor;
				sym->align=sect->align;
				sect->align=0;
			}
		}
	}
}


void section_declarecommon(struct section *sect,const char *lab,int size,int global)
{
	int flags=global ? 0 : SYMBOLFLAG_LOCAL;
	if(sect->cursor && sect->bss==0)
		asmerror("Can't mix BSS and code/initialised data in a section.");
	section_declaresymbol(sect,lab,flags);
	sect->bss=1;
	sect->cursor+=size;
}


void section_addreference(struct section *sect, struct symbol *sym)
{
	if(sect->lastref)
		sect->lastref->next=sym;
	else
		sect->refs=sym;
	sect->lastref=sym;
}

void section_declarereference(struct section *sect, const char *name,int flags)
{
	struct symbol *sym;
	if(sect && name)
	{
		sym=symbol_new(name,sect->cursor,flags);
		if(sect->lastref)
			sect->lastref->next=sym;
		else
			sect->refs=sym;
		sect->lastref=sym;
	}
}


void section_align(struct section *sect,int align)
{
	if(sect)
		sect->align=align;
}


void section_emitbyte(struct section *sect,unsigned char byte)
{
	if(sect)
	{
		if(sect->bss)
			asmerror("Can't mix BSS and code/initialised data in a section.");

		// Do we need to start a new buffer?
		if(!codebuffer_write(sect->lastcodebuffer,byte))
		{
			struct codebuffer *buf=codebuffer_new();
			if(sect->lastcodebuffer)
				sect->lastcodebuffer->next=buf;
			else
				sect->codebuffers=buf;
			sect->lastcodebuffer=buf;
			codebuffer_write(sect->lastcodebuffer,byte);
		}
		++sect->cursor;
	}
}


void section_loadchunk(struct section *sect,int bytes,FILE *f)
{
	if(sect)
	{
		struct codebuffer *buf=codebuffer_new();
		if(sect->lastcodebuffer)
			sect->lastcodebuffer->next=buf;
		else
			sect->codebuffers=buf;
		sect->lastcodebuffer=buf;
		printf("Loading %d bytes\n",bytes);
		codebuffer_loadchunk(sect->lastcodebuffer,bytes,f);
		sect->cursor+=bytes;
		printf("Cursor: %d bytes\n",sect->cursor);
	}
}


void section_dump(struct section *sect)
{
	if(sect)
	{
		struct codebuffer *buf;
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
		sym=sect->refs;
		while(sym)
		{
			symbol_dump(sym);
			sym=sym->next;
		}

		printf("\nBinary data:\n");
		buf=sect->codebuffers;
		while(buf)
		{
			codebuffer_dump(buf);
			buf=buf->next;
		}
	}
}


void section_output(struct section *sect,FILE *f)
{
	if(sect)
	{
		struct codebuffer *buf;
		struct symbol *sym;
		int l;
		fputs("SECT",f);	
		write_lstr(sect->identifier,f);

		/* Output declared symbols */
		sym=sect->symbols;
		fputs("SYMB",f);
		while(sym)
		{
			symbol_output(sym,f);
			sym=sym->next;
		}
		fputc(0xff,f);

		/* Output references */
		sym=sect->refs;
		fputs("REFS",f);
		while(sym)
		{
			symbol_output(sym,f);
			sym=sym->next;
		}
		fputc(0xff,f);

		/* Output the binary data */
		buf=sect->codebuffers;
		if(buf)
		{
			fputs("BNRY",f);
			write_int_le(sect->cursor,f);
		}
		while(buf)
		{
			codebuffer_output(buf,f);
			buf=buf->next;
		}
	}
}

