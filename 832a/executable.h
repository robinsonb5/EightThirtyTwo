#ifndef EXECUTABLE_H
#define EXECUTABLE_H

#include "objectfile.h"

struct executable
{
	struct objectfile *objects;
	struct objectfile *lastobject;
};

struct executable *executable_new();
void executable_delete(struct executable *exe);

void executable_loadobject(struct executable *exe,const char *fn);

void executable_dump(struct executable *exe);

#endif
