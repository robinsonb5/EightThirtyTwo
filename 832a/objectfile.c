#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "832a.h"
#include "objectfile.h"

static unsigned char tmp[256];

struct objectfile *objectfile_new()
{
	struct objectfile *obj;
	obj=(struct objectfile *)malloc(sizeof(struct objectfile));
	if(obj)
	{
		obj->filename=0;
		obj->next=0;
		obj->sections=0;
		obj->lastsection=0;
	}
	return(obj);
}

/*
	Loading an object file is fairly straightforward, the only complication
    is loading the binary section to codebuffers.
	Need to avoid splitting a reference between buffers, otherwise resolving
	and relaxing references will get very complicated.
	When loading chunks, check symbols that fall within this buffer for alignment,
	and add headroom for expansion.
	Check references to make sure there isn't one beginning in the last
	(6+alignment headroom) bytes, and if so, reduce the chunk size accordingly.
*/

void objectfile_load(struct objectfile *obj,const char *fn)
{
	obj->filename=strdup(fn);
	FILE *f=fopen(fn,"rb");
	struct section *sect=0;
	struct symbol *sym;
	if(!f)
		linkerror("Can't open file");
	fread(tmp,2,1,f);
	if(tmp[0]!=0x83 || tmp[1]!=0x2a)
		linkerror("Not an 832 object file");

	while(fread(tmp,4,1,f))
	{
		int l;
		printf("Chunk header: %s\n",tmp);
		if(strncmp(tmp,"SECT",4)==0)
		{
			read_lstr(f,tmp);
			printf("Section %s :\n",tmp);
			sect=objectfile_addsection(obj,tmp);
		}
		else if(strncmp(tmp,"BNRY",4)==0)
		{
			l=read_int_le(f);
			printf("%d bytes of binary\n",l);
			/* FIXME - avoid splitting refs over ref boundaries */
			while(l>0)
			{
				section_loadchunk(sect,l>CODEBUFFERSIZE ? CODEBUFFERSIZE : l,f);
				l-=CODEBUFFERSIZE;
			}
		}
		else if(strncmp(tmp,"SYMB",4)==0)
		{
			fread(tmp,1,1,f);
			while(tmp[0]!=0xff)
			{
				int align=tmp[0];
				int flags;
				int cursor;
				fread(tmp,1,1,f);
				flags=tmp[0];
				cursor=read_int_le(f);
				read_lstr(f,tmp);
				printf("Symbol: %s, cursor %d, flags %x, align %d\n",tmp,cursor,flags,align);
				sym=symbol_new(tmp,cursor,flags);
				if(sect && sym)
				{
					sym->align=align;
					section_addsymbol(sect,sym);
				}
				fread(tmp,1,1,f);
			}
		}
		else if(strncmp(tmp,"REFS",4)==0)
		{
			fread(tmp,1,1,f);
			while(tmp[0]!=0xff)
			{
				int align=tmp[0];
				int flags;
				int cursor;
				fread(tmp,1,1,f);
				flags=tmp[0];
				cursor=read_int_le(f);
				read_lstr(f,tmp);
				printf("Ref: %s, cursor %d, flags %x, align %d\n",tmp,cursor,flags,align);
				sym=symbol_new(tmp,cursor,flags);
				if(sect && sym)
				{
					sym->align=align;
					section_addreference(sect,sym);
				}

				fread(tmp,1,1,f);
			}
		}
		else
			linkerror("Encountered bad chunk");
	}
	fclose(f);
}


struct section *objectfile_findsection(struct objectfile *obj,const char *sectionname)
{
	struct section *sect;
	if(!obj)
		return(0);
	sect=obj->sections;
	while(sect)
	{
		if(section_matchname(sect,sectionname))
			return(sect);
		sect=sect->next;
	}
	return(0);
}


struct section *objectfile_addsection(struct objectfile *obj, const char *sectionname)
{
	struct section *sect=section_new(sectionname);
	if(sect)
	{
		if(obj->lastsection)
			obj->lastsection->next=sect;
		else
			obj->sections=sect;
		obj->lastsection=sect;
	}
	return(sect);
}


void objectfile_delete(struct objectfile *obj)
{
	struct section *sect,*next;
	if(obj)
	{
		if(obj->filename)
			free(obj->filename);
		next=obj->sections;
		while(next)
		{
			sect=next;
			next=next->next;
			section_delete(sect);
		}
		free(obj);
	}	
}

void objectfile_dump(struct objectfile *obj)
{
	struct section *sect;
	sect=obj->sections;
	while(sect)
	{
		section_dump(sect);
		sect=sect->next;
	}
}


void objectfile_output(struct objectfile *obj,const char *filename)
{
	if(obj)
	{
		struct section *sect=obj->sections;

		FILE *f=fopen(filename,"wb");
		fputc(0x83,f);
		fputc(0x2a,f);

		while(sect)
		{
			section_output(sect,f);
			sect=sect->next;
		}
		fclose(f);
	}
}

