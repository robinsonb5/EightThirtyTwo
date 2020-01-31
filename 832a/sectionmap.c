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

int sectionmap_populate(struct executable *exe)
{
	int result=1;

	return(result);
}


