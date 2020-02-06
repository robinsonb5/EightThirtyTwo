#ifndef EXECUTABLE_H
#define EXECUTABLE_H

#include "objectfile.h"
#include "sectionmap.h"

struct executable
{
	struct objectfile *objects;
	struct objectfile *lastobject;
	struct sectionmap *map;
	int baseaddress;
};


struct executable *executable_new();
void executable_delete(struct executable *exe);

void executable_loadobject(struct executable *exe,const char *fn);
struct symbol *executable_findsymbol(struct executable *sect,const char *symname,struct section *excludesection);

void executable_setbaseaddress(struct executable *exe,int baseaddress);
void executable_link(struct executable *exe);
void executable_save(struct executable *exe,const char *fn);

void executable_dump(struct executable *exe,int untouched);

#endif
