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


/* Sort a subsection of the entry map */

int sectionmap_sort(struct sectionmap *map,int first, int last)
{

}


int sectionmap_populate(struct executable *exe)
{
	struct sectionmap *map=exe->map;
	map->entrycount=countsections(exe);
	printf("%d sections touched\n",map->entrycount);

	if(map->entries=malloc(sizeof(struct sectionmap_entry)*map->entrycount))
	{
		struct objectfile *obj=exe->objects;
		int idx=0;

		/* Collect together the non-ctor/dtor and non-bss sections first */
		while(obj)
		{
			struct section *sect=obj->sections;
			while(sect)
			{
				if((sect->flags&SECTIONFLAG_TOUCHED) &&
								(sect->flags&(SECTIONFLAG_CTOR|SECTIONFLAG_DTOR|SECTIONFLAG_BSS)==0))
					map->entries[idx++].sect=sect;
				sect=sect->next;
			}
			obj=obj->next;
		}

		/* Sort the sections by name (sorting is only vital for ctors/dtors' priorities */

		return(1);
	}
	return(0);
}


