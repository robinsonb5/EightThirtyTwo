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

void linkerror(const char *err)
{
	fprintf(stderr,"Error in %s - %s\n",error_file,err);
	exit(1);
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


int read_int_le(FILE *f)
{
	int result;
	unsigned char buf[4];
	fread(buf,4,1,f);
	result=(buf[3]<<24)|(buf[2]<<16)|(buf[1]<<8)|buf[0];
	return(result);
}

int read_short_le(FILE *f)
{
	int result;
	unsigned char buf[2];
	fread(buf,2,1,f);
	result=(buf[1]<<8)|buf[0];
	return(result);
}

void read_lstr(FILE *f,char *ptr)
{
	int l;
	fread(ptr,1,1,f);
	l=ptr[0];
	fread(ptr,l,1,f);
	ptr[l]=0;
}
