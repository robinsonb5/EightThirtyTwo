#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "sectionmap.h"
#include "symbol.h"

static struct section *sectionmap_addbuiltin(struct sectionmap *map,const char *id,int flags)
{
	struct section *sect=section_new(0,id);
	if(sect)
	{
		sect->flags|=flags;
		section_declaresymbol(sect,id,0);
		if(map->lastbuiltin)
			map->lastbuiltin->next=sect;
		else
			map->builtins=sect;
		map->lastbuiltin=sect;
	}
	return(sect);
}

struct sectionmap *sectionmap_new()
{
	struct sectionmap *result;
	result=(struct sectionmap *)malloc(sizeof(struct sectionmap));
	if(result)
	{
		result->entrycount=0;
		result->entries=0;
		result->builtins=0;
		result->lastbuiltin=0;
		sectionmap_addbuiltin(result,"__ctors_start__",SECTIONFLAG_CTOR);
		sectionmap_addbuiltin(result,"__ctors_end__",SECTIONFLAG_CTOR);
		sectionmap_addbuiltin(result,"__dtors_start__",SECTIONFLAG_DTOR);
		sectionmap_addbuiltin(result,"__dtors_end__",SECTIONFLAG_DTOR);
		sectionmap_addbuiltin(result,"__bss_start__",SECTIONFLAG_BSS);
		sectionmap_addbuiltin(result,"__bss_end__",SECTIONFLAG_BSS);
	}
	return(result);
}

void sectionmap_delete(struct sectionmap *map)
{
	if(map)
	{
		struct section *sect=map->builtins;
		while(sect)
		{
			struct section *next=sect->next;
			section_delete(sect);
			sect=next;
		}
		if(map->entries)
			free(map->entries);
		free(map);
	}
}


/* Return a count of the number of sections that have been touched while resolving references. */
static int countsections(struct executable *exe)
{
	struct section *sect=0;
	int result=0;
	if(exe)
	{
		struct objectfile *obj=exe->objects;
		sect=exe->map->builtins;
		while(sect)
		{
			if(sect->flags&SECTIONFLAG_TOUCHED)
				++result;
			sect=sect->next;
		}

		while(obj)
		{
			sect=obj->sections;
			while(sect)
			{
				if(sect->flags&SECTIONFLAG_TOUCHED)
					++result;
				sect=sect->next;
			}
			obj=obj->next;
		}
	}
	return(result);	
}


struct section *sectionmap_getbuiltin(struct sectionmap *map,int builtin)
{
	struct section *sect=map->builtins;
	while(builtin--)
		sect=sect ? sect->next : 0;
	return(sect);
}

/* Sort a subsection of the entry map */

int sectionmap_sort(struct sectionmap *map,int first, int last)
{

}


static int sectionmap_populate_inner(struct executable *exe,int idx,int flags)
{
	struct sectionmap *map=exe->map;
	struct objectfile *obj=exe->objects;

	/* Collect together the non-ctor/dtor and non-bss sections first */
	while(obj)
	{
		struct section *sect=obj->sections;
		while(sect)
		{
			if((sect->flags&SECTIONFLAG_TOUCHED) &&
							(sect->flags&(SECTIONFLAG_CTOR|SECTIONFLAG_DTOR|SECTIONFLAG_BSS)==flags))
				map->entries[idx++].sect=sect;
			sect=sect->next;
		}
		obj=obj->next;
	}
	return(idx);
}


int sectionmap_populate(struct executable *exe)
{
	int i;
	struct section *sect;
	struct sectionmap *map=exe->map;
	map->entrycount=countsections(exe);
	printf("%d sections touched\n",map->entrycount);

	if(map->entries=malloc(sizeof(struct sectionmap_entry)*map->entrycount))
	{
		struct objectfile *obj=exe->objects;
		int idxstart=0;
		int idx=0;

		/* Collect together the non-ctor/dtor and non-bss sections first */
		sectionmap_populate_inner(exe,idx,0);

		sect=sectionmap_getbuiltin(map,BUILTIN_CTORS_START);
		if(sect && sect->flags&SECTIONFLAG_TOUCHED)
		{
			map->entries[idx++].sect=sect;
			/* Now collect ctors...*/
			idxstart=idx;
			idx=sectionmap_populate_inner(exe,idx,SECTIONFLAG_CTOR);

			/* Sort ctors */

			sect=sectionmap_getbuiltin(map,BUILTIN_CTORS_END);
			map->entries[idx++].sect=sect;					
			sect=sectionmap_getbuiltin(map,BUILTIN_DTORS_START);
			map->entries[idx++].sect=sect;

			idxstart=idx;
			idx=sectionmap_populate_inner(exe,idx,SECTIONFLAG_DTOR);

			/* Sort dtors */

			sect=sectionmap_getbuiltin(map,BUILTIN_DTORS_END);
			map->entries[idx++].sect=sect;					

		}
		/* Collect BSS */
		sect=sectionmap_getbuiltin(map,BUILTIN_BSS_START);
		map->entries[idx++].sect=sect;

		idxstart=idx;
		idx=sectionmap_populate_inner(exe,idx,SECTIONFLAG_DTOR);

		sect=sectionmap_getbuiltin(map,BUILTIN_BSS_END);
		map->entries[idx++].sect=sect;					

		return(1);
	}
	return(0);
}


