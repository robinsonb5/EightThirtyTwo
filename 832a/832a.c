/* EightThirtyTwo assembler */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "832a.h"

#include "program.h"
#include "section.h"


static char *delims=" \t:\n\r,";



void directive_weak(struct program *prog,const char *tok,const char *tok2)
{
	struct section *sect=program_getsection(prog);
	struct symbol *sym;
	if(sect)
	{
		sym=section_getsymbol(sect,tok);
		if(sym)
			sym->flags|=SYMBOLFLAG_WEAK;
	}
}


void directive_global(struct program *prog,const char *tok,const char *tok2)
{
	struct section *sect=program_getsection(prog);
	struct symbol *sym;
	if(sect)
	{
		sym=section_getsymbol(sect,tok);
		if(sym)
			sym->flags|=SYMBOLFLAG_GLOBAL;
	}
}


void directive_section(struct program *prog,const char *tok,const char *tok2)
{
	program_setsection(prog,tok);
}


/* Emit literal values in little-endian form */
void directive_int(struct program *prog,const char *tok,const char *tok2)
{
	int v=strtoul(tok,0,0);
	program_emitbyte(prog,(v&255));
	program_emitbyte(prog,((v>>8)&255));
	program_emitbyte(prog,((v>>16)&255));
	program_emitbyte(prog,((v>>24)&255));
}


void directive_byte(struct program *prog,const char *tok,const char *tok2)
{
	int v=strtol(tok,0,0);
	program_emitbyte(prog,v&255);
}


void directive_short(struct program *prog,const char *tok,const char *tok2)
{
	int v=strtol(tok,0,0);
	program_emitbyte(prog,(v&255));
	program_emitbyte(prog,((v>>8)&255));
}


void directive_label(struct program *prog,const char *tok,const char *tok2)
{
	struct section *sect=program_getsection(prog);
	section_declaresymbol(sect,tok,0);
}


void directive_reloc(struct program *prog,const char *tok,const char *tok2)
{
	struct section *sect=program_getsection(prog);
	
	printf(".reloc: %s\n",tok);
}


void directive_lipcrel(struct program *prog,const char *tok,const char *tok2)
{
	struct section *sect=program_getsection(prog);
	if(sect)
	{
		section_declarereference(sect,tok,SYMBOLFLAG_PCREL);
		section_emitbyte(sect,0xc0);	/* Allow space for the worst-case of 6 bytes */
		section_emitbyte(sect,0xc0);	/* Will relax this at link-time */
		section_emitbyte(sect,0xc0);
		section_emitbyte(sect,0xc0);
		section_emitbyte(sect,0xc0);
		section_emitbyte(sect,0xc0);
	}
}


void directive_liabs(struct program *prog,const char *tok,const char *tok2)
{
	struct section *sect=program_getsection(prog);
	if(sect)
	{
		section_declarereference(sect,tok,SYMBOLFLAG_ABS);
		section_emitbyte(sect,0xc0);	/* Allow space for the worst-case of 6 bytes */
		section_emitbyte(sect,0xc0);	/* Will relax this at link-time */
		section_emitbyte(sect,0xc0);
		section_emitbyte(sect,0xc0);
		section_emitbyte(sect,0xc0);
		section_emitbyte(sect,0xc0);
	}
}


static int count_constantchunks(long v)
{
	int chunk = 1;
	long v2 = v;
	while (chunk<6 && ((v2 & 0xffffffe0) != 0) && ((v2 & 0xffffffe0) != 0xffffffe0))	// Are we looking at a sign-extended 6-bit value yet?
	{
		v2 >>= 6;
		// Sign-extend
		if(v2&0x02000000)
			v2|=0xfc000000;
		++chunk;
	}
	return (chunk);
}


void directive_liconst(struct program *prog,const char *tok,const char *tok2)
{
	long v=strtol(tok,0,0);
	int chunk=count_constantchunks(v);
	printf("%d chunks\n",chunk);
	while(chunk--)
	{
		int c=(v>>(6*chunk))&0x3f;
		c|=0xc0;
		printf("Emitting chunk %d, %x\n",chunk,c);
		program_emitbyte(prog,c);
	}
}


void directive_align(struct program *prog,const char *tok,const char *tok2)
{
	int align=atoi(tok);
	struct section *sect=program_getsection(prog);
	section_align(sect,align);
}


void directive_comm(struct program *prog,const char *tok,const char *tok2)
{
	int size=atoi(tok2);
	struct section *sect=program_getsection(prog);
	section_declarecommon(sect,tok,size,1);
}


void directive_lcomm(struct program *prog,const char *tok,const char *tok2)
{
	int size=atoi(tok2);
	struct section *sect=program_getsection(prog);
	section_declarecommon(sect,tok,size,0);
}


struct directive
{
	char *mnem;
	void (*handler)(struct program *prog,const char *token,const char *token2);
};

struct directive directives[]=
{
	{".align",directive_align},
	{".weak",directive_weak},
	{".global",directive_global},
	{".globl",directive_global},
	{".section",directive_section},
	{".comm",directive_comm},
	{".lcomm",directive_lcomm},
	{".int",directive_int},
	{".short",directive_short},
	{".byte",directive_byte},
	{".reloc",directive_reloc},
	{".liconst",directive_liconst},
	{".liabs",directive_liabs},
	{".lipcrel",directive_lipcrel},
	{0,0}
};


/* Attempt to assemble the named file.  Calls exit() on failure. */
int assemble(const char *fn,const char *on)
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
			char *tok,*tok2,*tok3;
			++line;
			error_setline(line);
			if(tok=strtok(linebuf,delims))
			{
				int d;
				tok3=tok2=strtok(0,delims);
				if(tok2)
					tok3=strtok(0,delims);
				/* comments */
				if((tok[0]=='/' && tok[1]=='/') || tok[0]==';' || tok[0]=='#')
					continue;
				/* Labels starting at column zero */
				if(linebuf[0]!=' ' && linebuf[0]!='\t' && linebuf[0]!='\n' && linebuf[0]!='\r')
				{
					directive_label(prog,tok,0);
				}
				else
				{
					/* Search the directives table */
					d=0;
					while(directives[d].mnem)
					{
						if(strcasecmp(tok,directives[d].mnem)==0)
						{
							directives[d].handler(prog,tok2,tok3);
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
								if(tok2 && opcodes[o].opbits==3) /* 3 bit literals - register or condition code */
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
								else if(tok2 && opcodes[o].opbits==6) /* 6 bit literal - immediate value */
								{
									int v=strtoul(tok2,0,0);
									v&=0x3f;
									opc|=v;
								}
								printf("%s\t%s -> 0x%x\n",tok, tok2 && opcodes[o].opbits ? tok2 : "", opc);
								program_emitbyte(prog,opc);
								break;
							}
							++o;
						}
						if(!opcodes[o].mnem)
							asmerror("syntax error\n");
					}
				}
			}
		}
		if(linebuf)
			free(linebuf);
		fclose(f);
	}
	program_output(prog,on);
	program_dump(prog);
	program_delete(prog);
	printf("Output file: %s\n",on);

	return(0);
}

char *objname(const char *srcname)
{
	int l=strlen(srcname);
	int i;
	char *result=malloc(l+3);
	strcpy(result,srcname);
	for(i=l;i>0;--i)
	{
		if(result[i]=='.')
		{
			result[i+1]='o';
			result[i+2]=0;
			return(result);
		}
	}
	result[l]='.';
	result[l+1]='o';
	result[l+2]=0;
	return(result);
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
			char *on=objname(argv[i]);
			assemble(argv[i],on);
			free(on);
		}
	}
	return(result);
}

