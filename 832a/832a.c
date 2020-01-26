/* EightThirtyTwo assembler */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "832a.h"

#include "program.h"
#include "section.h"


static char *delims=" \t:\n\r";



void directive_weak(struct program *prog,const char *tok)
{
	printf("weak: %s\n",tok);
}


void directive_global(struct program *prog,const char *tok)
{
	printf("global: %s\n",tok);
}


void directive_section(struct program *prog,const char *tok)
{
	program_setsection(prog,tok);
}

/* Emit literal values in little-endian form */
void directive_int(struct program *prog,const char *tok)
{
	int v=strtoul(tok,0,0);
	program_emitbyte(prog,(v&255));
	program_emitbyte(prog,((v>>8)&255));
	program_emitbyte(prog,((v>>16)&255));
	program_emitbyte(prog,((v>>24)&255));
//	printf(".int: %s\n",tok);
}


void directive_byte(struct program *prog,const char *tok)
{
	int v=strtol(tok,0,0);
	program_emitbyte(prog,v&255);
//	printf(".byte: 0x%x\n",v);
}


void directive_short(struct program *prog,const char *tok)
{
	int v=strtol(tok,0,0);
	program_emitbyte(prog,(v&255));
	program_emitbyte(prog,((v>>8)&255));
//	printf(".short: %s\n",tok);
}


void directive_label(struct program *prog,const char *tok)
{
	struct section *sect=program_getsection(prog);
	section_addsymbol(sect,tok);
}


void directive_reloc(struct program *prog,const char *tok)
{
	struct section *sect=program_getsection(prog);
	
	printf(".reloc: %s\n",tok);
}


void directive_pcrel(struct program *prog,const char *tok)
{
	struct section *sect=program_getsection(prog);
	
	printf(".pcrel: %s\n",tok);
}


struct directive
{
	char *mnem;
	void (*handler)(struct program *prog,const char *token);
};

struct directive directives[]=
{
	{".weak",directive_weak},
	{".global",directive_global},
	{".section",directive_section},
	{".int",directive_int},
	{".short",directive_short},
	{".byte",directive_byte},
	{".reloc",directive_reloc},
	{".pcrel",directive_pcrel},
	{0,0}
};


/* Attempt to assemble the named file.  Calls exit() on failure. */
int assemble(const char *fn)
{
	FILE *f;
	struct program *prog;

	prog=program_new();
	if(!prog)
		return(0);

	printf("Opening file %s\n",fn);
	
	if(f=fopen(fn,"r"))
	{
		int line=0;
		char *linebuf=0;
		size_t len;
		int c;
		error_setfile(fn);
		while(c=getline(&linebuf,&len,f)>0)
		{
			char *tok,*tok2;
			++line;
			error_setline(line);
			if(tok=strtok(linebuf,delims))
			{
				int d;
				tok2=strtok(0,delims);
				/* comments */
				if((tok[0]=='/' && tok[1]=='/') || tok[0]==';' || tok[0]=='#')
					continue;
				/* Labels starting at column zero */
				if(linebuf[0]!=' ' && linebuf[0]!='\t' && linebuf[0]!='\n' && linebuf[0]!='\r')
				{
					directive_label(prog,tok);
				}
				else
				{
					/* Search the directives table */
					d=0;
					while(directives[d].mnem)
					{
						if(strcasecmp(tok,directives[d].mnem)==0)
						{
							directives[d].handler(prog,tok2);
							break;
						}
						++d;
					}
					/* Not a directive?  Interpret as an opcode... */
					if(!directives[d].mnem)
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
										asmerror("bad register");
								}
								printf("%s\t%s -> 0x%x\n",tok, tok2 && opcodes[o].opbits ? tok2 : "", opc);
								program_emitbyte(prog,opc);
								break;
							}
							++o;
						}
					}
				}
			}
		}
		if(linebuf)
			free(linebuf);
		fclose(f);
	}
	program_dump(prog);
	program_delete(prog);
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

