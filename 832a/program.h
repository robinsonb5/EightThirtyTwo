#ifndef PROGRAM_H
#define PROGRAM_H

#include "section.h"

struct program
{
	struct section *sections;
	struct section *lastsection;
	struct section *currentsection;
};

struct program *program_new();
void program_delete(struct program *prog);

void program_setsection(struct program *prog, const char *sectionname);
struct section *program_getsection(struct program *prog);
struct section *program_addsection(struct program *prog, const char *sectionname);
struct section *program_findsection(struct program *prog,const char *sectionname);

void program_emitbyte(struct program *prog,unsigned char byte);


void program_dump(struct program *prog);

#endif

