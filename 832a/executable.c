#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "executable.h"

struct executable *executable_new()
{
	struct executable *result=(struct executable *)malloc(sizeof(struct executable));
	if(result)
	{
		result->objects=0;
		result->lastobject=0;
	}
	return(result);
}

void executable_delete(struct executable *exe)
{
	if(exe)
	{
		struct objectfile *obj,*next;
		next=exe->objects;
		while(next)
		{
			obj=next;
			next=obj->next;
			objectfile_delete(obj);
		}
		free(exe);
	}
}

void executable_loadobject(struct executable *exe,const char *fn)
{
	if(exe)
	{
		struct objectfile *obj=objectfile_new();
		if(exe->lastobject)
			exe->lastobject->next=obj;
		else
			exe->objects=obj;
		exe->lastobject=obj;

		objectfile_load(obj,fn);
	}
}

void executable_dump(struct executable *exe)
{
	struct objectfile *obj;
	obj=exe->objects;
	while(obj)
	{
		objectfile_dump(obj);
		obj=obj->next;
	}
}


