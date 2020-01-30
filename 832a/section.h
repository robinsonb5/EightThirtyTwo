#ifndef SECTION_H
#define SECTION_H

#include "codebuffer.h"
#include "symbol.h"
#include "objectfile.h"

struct section
{
	struct section *next;
	char *identifier;
	int address;
	int cursor;
	int align;
	int bss;
	int touched;
	struct codebuffer *codebuffers;
	struct codebuffer *lastcodebuffer;
	struct symbol *symbols;
	struct symbol *lastsymbol;
	struct symbol *refs;
	struct symbol *lastref;
	struct objectfile *obj;
};

struct section *section_new(struct objectfile *obj,const char *name);
void section_clear(struct section *sect);
void section_delete(struct section *sect);

/* Section names are case-sensitive */
int section_matchname(struct section *sect,const char *name);
void section_touch(struct section *sect);

struct symbol *section_findsymbol(struct section *sect,const char *symname);
struct symbol *section_getsymbol(struct section *sect, const char *symname);
void section_declaresymbol(struct section *sect, const char *name,int flags);
void section_addsymbol(struct section *sect, struct symbol *sym);

void section_addreference(struct section *sect, struct symbol *sym);
void section_declarereference(struct section *sect, const char *name,int flags);

void section_declarecommon(struct section *sect,const char *lab,int size,int global);
void section_declareabsolute(struct section *sect,const char *lab,int size,int global);
void section_emitbyte(struct section *sect,unsigned char byte);
void section_align(struct section *sect,int align);

void section_loadchunk(struct section *sect,int bytes,FILE *f);
void section_output(struct section *sect,FILE *f);
void section_dump(struct section *sect);

#endif

