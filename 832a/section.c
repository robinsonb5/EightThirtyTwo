#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "832util.h"
#include "section.h"

struct section *section_new(struct objectfile *obj,const char *name)
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
		sect->cursor=0;
		sect->flags=0;
		sect->obj=obj;
		sect->address=0;
		sect->offset=0;
	}
	return(sect);
}


void section_touch(struct section *sect)
{
	if(sect)
		sect->flags|=SECTIONFLAG_TOUCHED;
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
	sym->sect=sect;
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
			section_addsymbol(sect,sym);
		}
		return(sym);
	}
}


/*	Hunts for an existing symbol; if it has been referenced but not
	declared, declares it, otherwise creates a new symbol.
	If it's been declared already throw an error.
*/
 
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
			}
		}
	}
}


void section_declarecommon(struct section *sect,const char *lab,int size,int global)
{
	int flags=global ? SYMBOLFLAG_GLOBAL : SYMBOLFLAG_LOCAL;
	if(sect->symbols && !(sect->flags&SECTIONFLAG_BSS))
		asmerror("Can't mix BSS and code/initialised data in a section.");
	section_declaresymbol(sect,lab,flags);
	sect->flags|=SECTIONFLAG_BSS;
	sect->cursor+=size;
}


void section_declareconstant(struct section *sect,const char *lab,int value,int global)
{
	struct symbol *sym;
	int flags=global ? SYMBOLFLAG_CONSTANT : SYMBOLFLAG_CONSTANT|SYMBOLFLAG_LOCAL;
	if(sym=section_getsymbol(sect,lab))
	{
		sym->cursor=value;
		sym->flags|=flags;
	}
}


void section_addreference(struct section *sect, struct symbol *sym)
{
	if(sect->lastref)
		sect->lastref->next=sym;
	else
		sect->refs=sym;
	sect->lastref=sym;
	sym->sect=sect;
}


void section_declarereference(struct section *sect, const char *name,int flags)
{
	struct symbol *sym;
	if(sect && sect->flags&SECTIONFLAG_BSS)
		asmerror("Can't mix BSS and code/initialised data in a section.");
	if(sect && name)
	{
		sym=symbol_new(name,sect->cursor,flags);
		section_addreference(sect,sym);
	}
}


/* Add an alignment ref to the section */
void section_align(struct section *sect,int align)
{
	if(sect)
	{
		struct symbol *sym;
		/* Reduce the cursor position by 1 so that it immediately precedes the
		   object to be aligned */
		sym=symbol_new("algn",sect->cursor-1,SYMBOLFLAG_ALIGN);
		sym->align=align;
		section_addreference(sect,sym);
	}
}


void section_emitbyte(struct section *sect,unsigned char byte)
{
	if(sect)
	{
		if(sect->flags&SECTIONFLAG_BSS)
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


void section_sizereferences(struct section *sect)
{
	if(sect)
	{
		struct symbol *sym=sect->refs;
		sect->offset=0;
		while(sym)
		{
			reference_size(sym);
			sect->offset+=sym->size;
			sym=sym->next;
		}
	}
}


void section_assignaddresses(struct section *sect,struct section *prev)
{
	struct symbol *ref=sect->refs;
	struct symbol *sym=sect->symbols;
	int cursor=0;
	int addr=0;
	if(!sect)
		return;
	if(prev)
	{
		addr=prev->address+prev->cursor+prev->offset;
	}
	printf("Assign addresses %x to %s\n",addr,sect->identifier);
	sect->address=addr;

	addr=0;

	/* Step through symbols, assigning addresses.
	   For each symbol, incorporate sizes into the section's offset values,
	   and use these to compute the symbols' address. */
	
	while(sym || ref)
	{
		if(sym)
			cursor=sym->cursor;
		else
			cursor=sect->cursor;

		while(ref && ref->cursor<=cursor)
		{
			if(ref->flags&SYMBOLFLAG_ALIGN)
			{
				int alignaddr=sect->address+ref->cursor+addr+1;
				/* If this is an alignment ref, apply it rather than using a theoretical best/worst case */
				printf("Best case: aligning %x to %d byte boundary\n",alignaddr,ref->align);
				alignaddr+=ref->align-1;
				alignaddr&=~(ref->align-1);
				ref->size=alignaddr-(sect->address+ref->cursor+addr+1);
				printf("  -> %x (%d)\n",alignaddr,ref->size);
				addr+=ref->size;
			}
			else
			{
				addr+=ref->size;
			}
			ref=ref->next;
		}

		if(sym)
		{
			if(!(sym->flags&SYMBOLFLAG_CONSTANT))
			{
				sym->address=sect->address+sym->cursor+addr;
			}
			sym=sym->next;
		}
	}
	sect->offset=addr;
}


void section_dump(struct section *sect,int untouched)
{
	if(sect)
	{
		if(untouched || (sect->flags&SECTIONFLAG_TOUCHED))
		{
			struct codebuffer *buf;
			struct symbol *sym;
			printf("\nSection: %s  :  ",sect->identifier);
			printf("cursor: %x",sect->cursor);
			printf("%s",sect->flags & SECTIONFLAG_BSS ? ", BSS" : "");
			printf("%s",sect->flags & SECTIONFLAG_CTOR ? ", CTOR" : "");
			printf("%s",sect->flags & SECTIONFLAG_DTOR ? ", DTOR" : "");
			printf("%s\n",sect->flags & SECTIONFLAG_TOUCHED ? ", touched" : "");
			printf("  Address: %x\n",sect->address);

			printf("\nSymbols:\n");
			sym=sect->symbols;
			while(sym)
			{
				printf("  ");
				symbol_dump(sym);
				sym=sym->next;
			}

			printf("\nReferences:\n");
			sym=sect->refs;
			while(sym)
			{
				printf("  ");
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
}


void section_outputobj(struct section *sect,FILE *f)
{
	if(sect)
	{
		struct codebuffer *buf;
		struct symbol *sym;
		int l;
		fputs("SECT",f);	
		write_lstr(sect->identifier,f);
		write_int_le(sect->flags,f);

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
			while(buf)
			{
				codebuffer_output(buf,f);
				buf=buf->next;
			}
		}
		else
		{
			fputs("BSS ",f);
			write_int_le(sect->cursor,f);
		}
	}
}


void section_outputexe(struct section *sect,FILE *f)
{
	int offset=0;
	int cbcursor=0;
	int newcbcursor=0;
	int cursor=0;
	int newcursor=0;
	struct symbol *ref=sect->refs;
	struct codebuffer *buffer=sect->codebuffers;
	if(!sect)
		return;

	if(sect->flags&SECTIONFLAG_BSS) /* Don't output any data for BSS. */
		return;

	/* Step through symbols and refs, outputting any binary code between refs,
	   and inserting refs. */

	while(cursor<sect->cursor)
	{
		if(ref)
		{
			newcursor=ref->cursor;
			if(ref->flags&SYMBOLFLAG_ALIGN)
				newcursor+=1;
		}
		else
			newcursor=sect->cursor;

		printf("writing %d bytes\n",newcursor-cursor);
		newcbcursor=cbcursor+(newcursor-cursor);

		while(newcbcursor>=CODEBUFFERSIZE)
		{
			fwrite(buffer->buffer,CODEBUFFERSIZE-cbcursor,1,f);
			cbcursor=0;
			newcbcursor-=CODEBUFFERSIZE;
			buffer=buffer->next;
		}
		if(newcbcursor)
			fwrite(buffer->buffer+cbcursor,newcbcursor-cbcursor,1,f);
		cbcursor=newcbcursor;

		if(ref)
		{
			if(ref->flags&SYMBOLFLAG_ALIGN)
			{
				int align=ref->size;
				offset+=align;
				printf("Outputting alignment reference %s, %d bytes\n",ref->identifier,align);
				while(align--)
					fputc(0,f);
			}
			else if(ref->flags&SYMBOLFLAG_LDPCREL)
			{
				int i;
				int targetaddr=ref->resolve->address;
				int refaddr=sect->address+ref->cursor+ref->size+offset+1;
				int d=targetaddr-refaddr;
				printf("Outputting ldpcrel reference %s, %d bytes\n",ref->identifier,ref->size);
				printf("Target address %x, reference address %x\n",targetaddr,refaddr);
				for(i=ref->size-1;i>=0;--i)
				{
					int c=((d>>(i*6))&0x3f)|0xc0;	/* Construct an 'li' opcode with six bits of data */
					fputc(c,f);
				}
				offset+=ref->size;
			}
			else if(ref->flags&SYMBOLFLAG_LDABS)
			{
				int i;
				int targetaddr=ref->resolve->address;
				int refaddr=sect->address+ref->cursor+ref->size+offset;
				int d=targetaddr;
				printf("Outputting ldabs reference %s, %d bytes\n",ref->identifier,ref->size);
				printf("Target address %x\n",targetaddr);
				for(i=ref->size-1;i>=0;--i)
				{
					int c=((d>>(i*6))&0x3f)|0xc0;	/* Construct an 'li' opcode with six bits of data */
					fputc(c,f);
				}
				offset+=ref->size;
			}
			else if(ref->flags&SYMBOLFLAG_REFERENCE)
			{
				printf("Outputting standard reference %s\n",ref->identifier);
				write_int_le(ref->resolve->address,f);
				offset+=4;
			}
			ref=ref->next;
		}
		cursor=newcursor;
	}
}

