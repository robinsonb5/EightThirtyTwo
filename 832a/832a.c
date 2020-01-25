/* EightThirtyTwo assembler */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "832a.h"

static char *delims=" \t:\n\r";


void error(const char *fn,int line, const char *err)
{
	fprintf(stderr,"Syntax error in %s, line %d - %s\n",fn,line,err);
	exit(1);
}

/* Attempt to assemble the named file.  Calls exit() on failure. */
int assemble(const char *fn)
{
	FILE *f;
	printf("Opening file %s\n",fn);
	
	if(f=fopen(fn,"r"))
	{
		int line=0;
		char *linebuf=0;
		size_t len;
		int c;
		while(c=getline(&linebuf,&len,f)>0)
		{
			char *tok,*tok2;
			++line;
			if(tok=strtok(linebuf,delims))
			{
				tok2=strtok(0,delims);
				if(tok[0]=='/' && tok[1]=='/')
					continue;
				if(linebuf[0]!=' ' && linebuf[0]!='\t' && linebuf[0]!='\n' && linebuf[0]!='\r')
				{
					printf("Label: %s\n",tok);
				}
				else if(strcasecmp(tok,".global")==0)
				{
					if(tok2)
						printf("Global symbol: %s\n",tok2);
					else
						error(fn,line,".symbol");
				}
				else if(strcasecmp(tok,".weak")==0)
				{
					if(tok2)
						printf("Symbol with weak linkage: %s\n",tok2);
					else
						error(fn,line,".weak");
				}
				else
				{
					int o=0;
					while(opcodes[o].mnem)
					{
						if(strcasecmp(tok,opcodes[o].mnem)==0)
						{
							int opc=opcodes[o].opcode;
							if(tok2 && opcodes[o].opbits==3)
							{
								int r=0;
								while(operands[r].mnem)
								{
									if(strcasecmp(tok2,operands[r].mnem)==0)
									{
										opc+=operands[r].opcode;
										break;
									}
									++r;
								}
								if(!operands[r].mnem)
									error(fn,line,"bad register");
							}
							printf("%s\t%s -> 0x%x\n",tok, tok2 && opcodes[o].opbits ? tok2 : "", opc);
							break;
						}
						++o;
					}
				}
			}
		}
		if(linebuf)
			free(linebuf);
		fclose(f);
	}
	else
		return(0);
}


int main(int argc, char **argv)
{
	int i;
	int result=0;
	if(argc==1)
	{
		fprintf(stderr,"Usage: %s file.s <file2.s> ...\n",argv[0]);
		result=1;
	}
	else
	{
		for(i=1;i<argc;++i)
		{
			if(!assemble(argv[i]))
				result=1;
		}
	}
	return(result);
}

