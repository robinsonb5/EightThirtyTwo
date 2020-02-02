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

	UPDATE:
	Sidestepped this issue entirely by leaving out the placeholder bytes, so the
	assembler now just emits the reference table and leaves the linker to insert
	the correct number of bytes.
*/

void objectfile_load(struct objectfile *obj,const char *fn)
{
	obj->filename=strdup(fn);
	FILE *f=fopen(fn,"rb");
	struct section *sect=0;
	struct symbol *sym;
	if(!f)
		linkerror("Can't open file");
	fread(tmp,4,1,f);
	if(strncmp(tmp,"832\x01",4)!=0)
		linkerror("Not an 832 object file");

	while(fread(tmp,4,1,f))
	{
		int l;
		printf("Chunk header: %s\n",tmp);
		if(strncmp(tmp,"832\x01",4)==0)	/* Another header - probably means objects have been concatenated. */
			;
		else if(strncmp(tmp,"SECT",4)==0)
		{
			read_lstr(f,tmp);
			printf("Section %s :\n",tmp);
			sect=objectfile_addsection(obj,tmp);
			sect->flags=read_int_le(f);
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
	struct section *sect=section_new(obj,sectionname);
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


struct section *objectfile_setsection(struct objectfile *obj, const char *sectionname)
{
	struct section *sect=objectfile_findsection(obj,sectionname);
	if(sect)
		obj->currentsection=sect;
	else
		obj->currentsection=objectfile_addsection(obj,sectionname);	
	return(obj->currentsection);
}


/* Return the current section.  If none has yet been defined, create one called ".text". */
struct section *objectfile_getsection(struct objectfile *obj)
{
	if(!obj->currentsection)
		objectfile_setsection(obj,".text");
	return(obj->currentsection);
}


void objectfile_emitbyte(struct objectfile *obj,unsigned char byte)
{
	if(obj)
		section_emitbyte(objectfile_getsection(obj),byte);
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

void objectfile_dump(struct objectfile *obj,int untouched)
{
	struct section *sect;
	printf("\nObjectfile: %s\n",obj->filename);
	sect=obj->sections;
	while(sect)
	{
		section_dump(sect,untouched);
		sect=sect->next;
	}
}


void objectfile_output(struct objectfile *obj,const char *filename)
{
	if(obj)
	{
		struct section *sect=obj->sections;

		FILE *f=fopen(filename,"wb");
		fwrite("832",3,1,f);
		fputc(0x01,f);

		while(sect)
		{
			section_output(sect,f);
			sect=sect->next;
		}
		fclose(f);
	}
}

