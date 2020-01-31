#ifndef EXECUTABLE_H
#define EXECUTABLE_H

#include "objectfile.h"
#include "sectionmap.h"

struct executable
{
	struct objectfile *objects;
	struct objectfile *lastobject;
	struct sectionmap *map;
	int firstbss;
	int lastbss;
};


struct executable *executable_new();
void executable_delete(struct executable *exe);

void executable_loadobject(struct executable *exe,const char *fn);
void executable_checkreferences(struct executable *exe);
struct symbol *executable_findsymbol(struct executable *sect,const char *symname,struct section *excludesection);

void executable_dump(struct executable *exe);

#endif
