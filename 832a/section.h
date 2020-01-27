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
	int align;
	int bss;
	struct codebuffer *codebuffers;
	struct codebuffer *lastcodebuffer;
	struct symbol *symbols;
	struct symbol *lastsymbol;
	struct symbol *refs;
	struct symbol *lastref;
};

struct section *section_new(const char *name);
void section_delete(struct section *sect);

/* Section names are case-sensitive */
int section_matchname(struct section *sect,const char *name);

struct symbol *section_findsymbol(struct section *sect,const char *symname);
struct symbol *section_getsymbol(struct section *sect, const char *symname);
void section_declaresymbol(struct section *sect, const char *name,int flags);

void section_addreference(struct section *sect, const char *name,int flags);

void section_declarecommon(struct section *sect,const char *lab,int size,int global);
void section_emitbyte(struct section *sect,unsigned char byte);
void section_align(struct section *sect,int align);

void section_loadchunk(struct section *sect,int bytes,FILE *f);
void section_output(struct section *sect,FILE *f);
void section_dump(struct section *sect);

#endif

