/* EightThirtyTwo assembler */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static char *delims=" \t:\n\r";

void error(const char *fn,int line, const char *err)
{
	fprintf(stderr,"Syntax error in %s, line %d - %s\n",fn,line,err);
	exit(1);
}


struct opcode
{
	const char *mnem;
	int opcode;
	int opbits;
};

struct opcode operands[]=
{
	/* Operand definitions - registers first */
	{"r0",0,0},
	{"r1",1,0},
	{"r2",2,0},
	{"r3",3,0},
	{"r4",4,0},
	{"r5",5,0},
	{"r6",6,0},
	{"r7",7,0},

	{"NEX",0},	/* Match none. */
	{"SGT",1},	/* Zero clear, carry clear */
	{"EQ",2},	/* Zero set, carry don't care */
	{"GE",3},	/* Zero set or carry clear */
	{"SLT",4},	/* Zero clear, carry set */
	{"NEQ",5},	/* Zero clear, carry don't care */
	{"LE",6},	/* Zero set or carry set */
	{"EX",7}	/* Zero don't care, carry don't care */
};

struct opcode opcodes[]=
{
	/* Regular opcodes, each taking a 3-bit operand specifying the register number */
	{"cond",0x00,3},
	{"exg",0x08,3},
	{"ldbinc",0x10,3},
	{"stdec",0x18,3},

	{"ldinc",0x20,3},
	{"shr",0x28,3},
	{"shl",0x30,3},
	{"ror",0x38,3},

	{"stinc",0x40,3},
	{"mr",0x08,3},
	{"stbinc",0x50,3},
	{"stmpdec",0x58,3},

	{"ldidx",0x60,3},
	{"ld",0x68,3},
	{"mt",0x70,3},
	{"st",0x78,3},

	{"add",0x00,3},
	{"sub",0x08,3},
	{"mul",0x10,3},
	{"and",0x18,3},

	{"addt",0xa0,3},
	{"cmp",0xa8,3},
	{"or",0xb0,3},
	{"xor",0xb8,3},

	/* Load immediate takes a six-bit operand */

	{"li",0xc0,6},

	/* Overloaded opcodes. Operands that make no sense when applied to r7, re-used.
	   No operand for obvious reasons. */

	{"sgn",0xb7,0}, /* Overloads or */
	{"ldt",0xbf,0}, /* Overloads xor */
	{"byt",0x97,0}, /* Overloads mul */
	{"hlf",0x9f,0} /* Overloads and */
};


/* Attempt to assemble the named file.  Returns 1 on success, 0 on failure. */
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
					int o;
					for(o=0;o<sizeof(opcodes)/sizeof(struct opcode);++o)
					{
						if(strcasecmp(tok,opcodes[o].mnem)==0)
						{
							int opc=opcodes[o].opcode;
							if(tok2 && opcodes[o].opbits==3)
							{
								int r;
								for(r=0;r<sizeof(operands)/sizeof(struct opcode);++r)
								{
									if(strcasecmp(tok2,operands[r].mnem)==0)
									{
										opc+=operands[r].opcode;
										r=sizeof(opcodes);
									}
								}
								if(r<sizeof(opcodes))
									error(fn,line,"bad register");
							}
							printf("%s\t%s -> 0x%x\n",tok, tok2 && opcodes[o].opbits ? tok2 : "", opc);
							o=sizeof(opcodes);
						}
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
