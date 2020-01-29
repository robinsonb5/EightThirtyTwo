#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "executable.h"


/*	Linked executable.  Linking procedure is as follows:
	* Read object files one by one.
	* Find duplicate symbols, find unresolvable references and garbage-collect unused sections:
		* Start with the first section, take each reference in turn
		* Find target symbols for all references, marking the section containing each reference as "touched".
			* If any references can't be found, throw an error
			* If we encounter a weak symbol at this stage, keep looking for a stronger one.
			* If a strong symbol is declared more than once, throw an error.
			* As each section is touched, recursively repeat the resolution process
			* Store pointers to both the target section and target symbol for each reference.
		* Remove any untouched sections.
	* Sort sections:
		* The first section must remain so
		* BSS sections should come last
		* Need to define virtual symbols at the start and end of the BSS sections
	* Assign preliminary addresses to all sections.
	* Calculate initial size of all sections, along with worst-case slack due to alignment
	* Resolve references.  Reference size in bytes will depend upon the reach/absolute address, so need
	  to support relaxation:
		* Move all bytes beyond the reference in the current codebuffer
		* Adjust the length of the codebuffer and the starting offset of subsequent buffers.
		* Adjust the section offset all symbols in the current section beyond the reference.
	* Assign final addresses to all symbols, taking alignment restrictions into account
	* Re-resolve all references using the symbols' final addresses.  No further adjustment should be required.
	* Save the linked executable
*/

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


/* Hunt for a symbol, but exclude a particular section from the search.
   If a weak symbol is found the search continues for a stronger one.
   If no non-weak version is found, the last version declared will be used.
   Need to return the current section as well.
 */
struct symbol *executable_findsymbol(struct executable *exe,const char *symname,struct section *excludesection)
{
	struct symbol *result=0;
	if(exe)
	{
		struct objectfile *obj=exe->objects;
		while(obj)
		{
			struct section *sect=obj->sections;
			while(sect)
			{
				if(sect!=excludesection)
				{
					struct symbol *sym=section_findsymbol(sect,symname);
					if(sym)
					{
						printf("%s's flags: %x, %x\n",symname,sym->flags,sym->flags&SYMBOLFLAG_GLOBAL);
						if(sym->flags&SYMBOLFLAG_WEAK)
						{
							printf("Weak symbol found - keep looking\n");
							result=sym; /* Use this result if nothing better is found */
						}
						else if((sym->flags&SYMBOLFLAG_GLOBAL)==0)
							printf("Symbol found but not globally declared - keep looking\n");
						else
							return(sym);
					}
				}
				sect=sect->next;
			}

			obj=obj->next;
		}
	}
	/* Return either zero or the most recently found weak instance */
	return(result);	
}


void executable_checkreferences(struct executable *exe)
{
	int result=1;
	if(exe)
	{
		struct objectfile *obj=exe->objects;
		while(obj)
		{
			struct section *sect=obj->sections;
			while(sect)
			{
				struct symbol *ref=sect->refs;
				while(ref)
				{
					struct symbol *sym=section_findsymbol(sect,ref->identifier);
					struct symbol *sym2;
					if(sym)
					{
						printf("Found symbol %s within the current section\n",sym->identifier);
					}
					if(!sym || (sym->flags&SYMBOLFLAG_WEAK))
					{
						printf("Symbol %s not found (or weak) - searching all sections...\n",ref->identifier);
						sym2=executable_findsymbol(exe,ref->identifier,sect);
					}
					if(!sym && !sym2)
					{
						fprintf(stderr,"\n*** %s - unresolved symbol: %s\n\n",obj->filename,ref->identifier);
						result=0;
					}
					ref=ref->next;
				}
				sect=sect->next;
			}

			obj=obj->next;
		}
		/* If we get this far all symbols were resolved so we can remove any unused sections */
		obj=exe->objects;
		while(obj)
		{
//			objectfile_garbagecollect(obj);
			obj=obj->next;
		}
	}
	if(!result)
		exit(1);
}
/*
	* Garbage-collect unused sections:
		* Start with the first section, take each reference in turn
		* Find target symbols for all references, marking the section containing each reference as "touched".
			* If any references can't be found, throw an error
			* If we encounter a weak symbol at this stage, keep looking for a stronger one.
			* As each section is touched, recursively repeat the resolution process
			* Store pointers to both the target section and target symbol for each reference.
		* Remove any untouched sections.
*/

