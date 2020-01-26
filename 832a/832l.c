#include <stdio.h>
#include <stdlib.h>

#include "832util.h"
#include "program.h"


void linkerr(const char *fn,const char *err)
{
	fprintf(stderr,"Error in %s, %s\n",fn,err);
	exit(1);
}


static unsigned char tmp[256];
static read_lstr(FILE *f,char *ptr)
{
	int l;
	fread(ptr,1,1,f);
	l=tmp[0];
	fread(ptr,l,1,f);
	tmp[l]=0;
}


void loadobj(const char *fn)
{
	FILE *f=fopen(fn,"rb");
	if(!f)
		linkerr(fn,"Can't open file");
	fread(tmp,2,1,f);
	if(tmp[0]!=0x83 || tmp[1]!=0x2a)
		linkerr(fn,"Not an 832 object file");

	while(fread(tmp,4,1,f))
	{
		int l;
		printf("Chunk header: %s\n",tmp);
		if(strncmp(tmp,"SECT",4)==0)
		{
			read_lstr(f,tmp);
			printf("Section %s :\n",tmp);
		}
		else if(strncmp(tmp,"BNRY",4)==0)
		{
			l=read_int_le(f);
			printf("%d bytes of binary\n",l);
			while(l>0)
			{
				fread(tmp,l>256 ? 256 : l,1,f);
				l-=256;
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
				fread(tmp,1,1,f);
			}
		}
		else
			linkerr(fn,"Encountered bad chunk");
	}
	fclose(f);
}


int main(int argc,char **argv)
{
	if(argc==1)
	{
		fprintf(stderr,"Usage: %s obj1.o <obj2.o> ... <-o output.bin>\n",argv[0]);
	}
	else
	{
		int i;
		int nextfn=0;
		char *outfn="a.out";
		for(i=1;i<argc;++i)
		{
			if(strcmp(argv[i],"-o")==0)
				nextfn=1;
			else if(nextfn==1)
			{
				outfn=argv[i];
				nextfn=0;
			}
			else
			{
				loadobj(argv[1]);
			}
		}
		printf("Linking and saving to %s\n",outfn);
	}
	return(0);
}

