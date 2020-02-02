#include <stdio.h>
#include <stdlib.h>

#include "832util.h"
#include "executable.h"
#include "objectfile.h"


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
		struct executable *exe=executable_new();
		if(exe)
		{
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

