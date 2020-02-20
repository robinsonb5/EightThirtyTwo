#ifndef OBJECTFILE_H
#define OBJECTFILE_H

#include "section.h"
#include "symbol.h"

struct objectfile
{
	char *filename;
	struct objectfile *next;
	struct section *sections;
	struct section *lastsection;
	struct section *currentsection;
};

struct objectfile *objectfile_new();
void objectfile_delete(struct objectfile *obj);

void objectfile_load(struct objectfile *obj,const char *fn);

struct section *objectfile_getsection(struct objectfile *obj);
struct section *objectfile_addsection(struct objectfile *obj, const char *sectionname);
struct section *objectfile_findsection(struct objectfile *obj,const char *sectionname);
struct section *objectfile_setsection(struct objectfile *obj, const char *sectionname);
struct symbol *objectfile_findsymbol(struct objectfile *obj, const char *symname);

void objectfile_dump(struct objectfile *obj,int untouched);

#endif

