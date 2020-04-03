#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "832util.h"
#include "executable.h"
#include "objectfile.h"


int main(int argc,char **argv)
{
	if(argc==1)
	{
		fprintf(stderr,"Usage: %s [options] obj1.o <obj2.o> ... <-o output.bin>\n",argv[0]);
		fprintf(stderr,"Options:\n");
		fprintf(stderr,"\t-e big|little\t- specify bit or little endian configuration\n");
		fprintf(stderr,"\t-o <file>\t- specify output file\n");
		fprintf(stderr,"\t-b <number>\t- specify base address\n");
		fprintf(stderr,"\t-m <mapfile>\t- write a map file\n");
		fprintf(stderr,"\t-s <symbol>=<number>\t- define symbol (such as stack size)\n");
		fprintf(stderr,"\t-d\t\t- enable debug messages\n");
	}
	else
	{
		int i;
		enum eightthirtytwo_endian endian=EIGHTTHIRTYTWO_LITTLEENDIAN;
		int nextfn=0;
		int nextbase=0;
		int nextsym=0;
		int nextmap=0;
		int nextendian=0;
		char *outfn="a.out";
		char *mapfn=0;
		struct executable *exe=executable_new();
		if(exe)
		{
			for(i=1;i<argc;++i)
			{
				if(strncmp(argv[i],"-m",2)==0)
					nextmap=1;
				else if(strncmp(argv[i],"-e",2)==0)
					nextendian=1;
				else if(strncmp(argv[i],"-o",2)==0)
					nextfn=1;
				else if(strncmp(argv[i],"-d",2)==0)
					setdebuglevel(1);
				else if(strncmp(argv[i],"-b",2)==0)
					nextbase=1;
				else if(!nextsym && strncmp(argv[i],"-s",2)==0)
					nextsym=1;
				else if(nextsym)
				{
					/* Deferred to a second pass so there's a section to add the symbol to. */
					nextsym=0;
				}
				else if(nextbase)
				{
					char *tmp;
					unsigned long addr=strtoul(argv[i],&tmp,0);
					if(*argv[i]=='=')
						++argv[i];
					if(tmp==argv[i] && addr==0)
						fprintf(stderr,"Bad base address - using 0\n");
					executable_setbaseaddress(exe,addr);
					nextbase=0;
				}
				else if(nextfn)
				{
					outfn=argv[i];
					nextfn=0;
				}
				else if(nextmap)
				{
					mapfn=argv[i];
					nextmap=0;
				}
				else if(nextendian)
				{
					if(*argv[i]=='l')
						endian=EIGHTTHIRTYTWO_LITTLEENDIAN;
					else if(*argv[i]=='b')
						endian=EIGHTTHIRTYTWO_BIGENDIAN;
					else
						linkerror("Endian flag must be \"little\" or \"big\"\n");
					nextendian=0;
				}
				else
				{
					error_setfile(argv[i]);
					executable_loadobject(exe,argv[i]);
				}

				/* Dirty trick for when we have an option with no space before the parameter. */
				if((*argv[i]=='-') && (strlen(argv[i])>2))
				{
					if(nextsym)
						nextsym=0;
					else
					{
						argv[i]+=2;
						--i;
					}
				}
			}

			/* Perform a second pass of the command line arguments to create symbols: */

			for(i=1;i<argc;++i)
			{
				if(strncmp(argv[i],"-s",2)==0)
					nextsym=1;
				else if(nextsym)
				{
					char *tok=strtok(argv[i],"= ");
					char *tok2=strtok(0,"= ");
					if(tok && tok2)
					{
						struct section *sect;
						char *endptr;
						unsigned long v=strtoul(tok2,&endptr,0);
						printf("Setting %s to %s\n",tok,tok2);
						if(!v && endptr==tok2)
							asmerror("Command-line symbol definition must be a number");
						/* Declare a symbol with constant value from the command line. */
						if(exe->objects)
							section_declareconstant(exe->objects->sections,tok,v,1);
					}
					nextsym=0;
				}

				/* Dirty trick for when we have an option with no space before the parameter. */
				if((*argv[i]=='-') && (strlen(argv[i])>2))
				{
					argv[i]+=2;
					--i;
				}
			}

			printf("Linking...\n");
			executable_link(exe);
			printf("Saving with %s endian configuration to %s\n",endian==EIGHTTHIRTYTWO_LITTLEENDIAN ? "little" : "big",outfn);
			executable_save(exe,outfn,endian);

			if(mapfn)
			{
				printf("Writing map file %s\n",mapfn);
				executable_writemap(exe,mapfn);
			}

			executable_delete(exe);
		}
	}
	return(0);
}

