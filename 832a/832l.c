#include <stdio.h>
#include <stdlib.h>

#include "832util.h"
#include "executable.h"
#include "objectfile.h"


int main(int argc,char **argv)
{
	if(argc==1)
	{
		fprintf(stderr,"Usage: %s [options] obj1.o <obj2.o> ... <-o output.bin>\n",argv[0]);
		fprintf(stderr,"Options:\n");
		fprintf(stderr,"\t-o <file>\t- specify output file\n");
		fprintf(stderr,"\t-b <number>\t- specify base address\n");
		fprintf(stderr,"\t-d\t\t- enable debug messages\n");
	}
	else
	{
		int i;
		int nextfn=0;
		int nextbase=0;
		char *outfn="a.out";
		struct executable *exe=executable_new();
		if(exe)
		{
			for(i=1;i<argc;++i)
			{
				if(strcmp(argv[i],"-o")==0)
					nextfn=1;
				else if(strcmp(argv[i],"-d")==0)
					setdebuglevel(1);
				else if(strcmp(argv[i],"-b")==0)
					nextbase=1;
				else if(nextbase==1)
				{
					char *tmp;
					unsigned long addr=strtoul(argv[i],&tmp,0);
					if(tmp==argv[i] && addr==0)
						fprintf(stderr,"Bad base address - using 0\n");
					executable_setbaseaddress(exe,addr);
					nextbase=0;
				}
				else if(nextfn==1)
				{
					outfn=argv[i];
					nextfn=0;
				}
				else
				{
					error_setfile(argv[i]);
					executable_loadobject(exe,argv[i]);
				}
			}
			printf("Linking...\n");
			executable_link(exe);
			printf("Saving to %s\n",outfn);
			executable_save(exe,outfn);

			executable_delete(exe);
		}
	}
	return(0);
}

