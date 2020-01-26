#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static const char *error_file;
static int error_line;

void error_setfile(const char *fn)
{
	error_file=fn;
}

void error_setline(int line)
{
	error_line=line;
}

void asmerror(const char *err)
{
	fprintf(stderr,"Error in %s, line %d - %s\n",error_file,error_line,err);
	exit(1);
}


void write_int_le(int i,FILE *f)
{
	fputc(i&255,f); i>>=8;
	fputc(i&255,f); i>>=8;
	fputc(i&255,f); i>>=8;
	fputc(i&255,f);
}

void write_short_le(int i,FILE *f)
{
	fputc(i&255,f); i>>=8;
	fputc(i&255,f);
}

void write_lstr(const char *str,FILE *f)
{
	int l=strlen(str);
	fputc(l,f);
	fputs(str,f);
}


