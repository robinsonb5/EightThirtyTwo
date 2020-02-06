#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>

static const char *error_file;
static int error_line;
static int debuglevel=0;

void setdebuglevel(int level)
{
	debuglevel=level;
}

void debug(int level,const char *fmt,...)
{
    va_list ap;
	va_start(ap,fmt);
	if(level<=debuglevel)
	{
		vprintf(fmt,ap);
	}
	va_end(ap);
}

void hexdump(int level,char *p,int l)
{
	int i=0;
	if(level<=debuglevel)
	{
		while(l--)
		{
			unsigned int t=*p++;
			unsigned int t2=(t>>4)&15;
			t2+='0'; if(t2>'9') t2+='@'-'9';
			putchar(t2);
			t2=t&15;
			t2+='0'; if(t2>'9') t2+='@'-'9';
			putchar(t2);
			++i;
			if((i&3)==0)
				putchar(' ');
			if((i&15)==0)
				putchar('\n');
		}
		putchar('\n');
	}
}

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

int count_constantchunks(long v)
{
	int chunk = 1;
	long v2 = v;
	while (chunk<6 && ((v2 & 0xffffffe0) != 0) && ((v2 & 0xffffffe0) != 0xffffffe0))
	/* Are we looking at a sign-extended 6-bit value yet? */
	{
		v2 >>= 6;
		// Sign-extend
		if(v2&0x02000000)
			v2|=0xfc000000;
		++chunk;
	}
	return (chunk);
}

