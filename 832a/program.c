#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "832a.h"
#include "program.h"


struct program *program_new()
{
	struct program *prog;
	prog=(struct program *)malloc(sizeof(struct program));
	if(prog)
	{
		prog->sections=0;
		prog->lastsection=0;
		prog->currentsection=0;
	}
	return(prog);
}


struct section *program_findsection(struct program *prog,const char *sectionname)
{
	struct section *sect;
	if(!prog)
		return(0);
	sect=prog->sections;
	while(sect)
	{
		if(section_matchname(sect,sectionname))
			return(sect);
		sect=sect->next;
	}
	return(0);
}


struct section *program_addsection(struct program *prog, const char *sectionname)
{
	struct section *sect=section_new(sectionname);
	if(sect)
	{
		if(prog->lastsection)
			prog->lastsection->next=sect;
		else
			prog->sections=sect;
		prog->lastsection=sect;
	}
	return(sect);
}


void program_setsection(struct program *prog, const char *sectionname)
{
	struct section *sect=program_findsection(prog,sectionname);
	if(sect)
		prog->currentsection=sect;
	else
		prog->currentsection=program_addsection(prog,sectionname);	
}


/* Return the current section.  If none has yet been defined, create one called ".text". */
struct section *program_getsection(struct program *prog)
{
	if(!prog->currentsection)
		program_setsection(prog,".text");
	return(prog->currentsection);
}


void program_emitbyte(struct program *prog,unsigned char byte)
{
	if(prog)
		section_emitbyte(program_getsection(prog),byte);
}


void program_delete(struct program *prog)
{
	struct section *sect,*next;
	if(prog)
	{
		next=prog->sections;
		while(next)
		{
			sect=next;
			next=next->next;
			section_delete(sect);
		}
		free(prog);
	}	
}

void program_dump(struct program *prog)
{
	struct section *sect;
	sect=prog->sections;
	while(sect)
	{
		section_dump(sect);
		sect=sect->next;
	}
}


void program_output(struct program *prog,const char *filename)
{
	if(prog)
	{
		struct section *sect=prog->sections;

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

