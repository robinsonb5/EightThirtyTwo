#ifndef SECTIONMAP_H
#define SECTIONMAP_H

#include "executable.h"
#include "section.h"

struct sectionmap_entry
{
	struct section *sect;
	int address;
};

#define BUILTIN_CTORS_START 0
#define BUILTIN_CTORS_END 1
#define BUILTIN_DTORS_START 0
#define BUILTIN_DTORS_END 1
#define BUILTIN_BSS_START 0
#define BUILTIN_BSS_END 1


struct sectionmap
{
	int entrycount;
	struct sectionmap_entry *entries;	/* Array, for speed and ease of sorting */
	struct section *builtins;	/* start and end markers for ctor/dtor/bss */
	struct section *lastbuiltin;
};

struct executable;
struct sectionmap *sectionmap_new();
void sectionmap_delete(struct sectionmap *map);
int sectionmap_populate(struct executable *exe);

#endif

