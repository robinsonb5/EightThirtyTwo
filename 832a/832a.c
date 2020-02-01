/* EightThirtyTwo assembler */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "832a.h"

#include "objectfile.h"
#include "section.h"


static char *delims=" \t:\n\r,";



void directive_sectionflags(struct objectfile *obj,const char *tok,const char *tok2,int key)
{
	struct section *sect=objectfile_getsection(obj);
	struct symbol *sym;
	if(sect)
	{
		sym=section_getsymbol(sect,tok);
		if(sym)
			sym->flags|=key;
	}
}


void directive_section(struct objectfile *obj,const char *tok,const char *tok2,int key)
{
	objectfile_setsection(obj,tok);
}


void directive_ctordtor(struct objectfile *obj,const char *tok,const char *tok2,int key)
{
	struct section *sect;
	if(sect=objectfile_setsection(obj,tok))
		sect->flags|=key;
}


/* Emit literal values in little-endian form */
void directive_literal(struct objectfile *obj,const char *tok,const char *tok2,int key)
{
	int v=strtoul(tok,0,0);
	objectfile_emitbyte(obj,(v&255));
	if(key>1)
		objectfile_emitbyte(obj,((v>>8)&255));
	if(key>2)
	{
		objectfile_emitbyte(obj,((v>>16)&255));
		objectfile_emitbyte(obj,((v>>24)&255));
	}
}


void directive_label(struct objectfile *obj,const char *tok,const char *tok2,int key)
{
	struct section *sect=objectfile_getsection(obj);
	section_declaresymbol(sect,tok,0);
}


/* Add one of several types of reference to the current section.
   The reference can be embedded-absolute, load-absolute or load-PC relative */

void directive_reloc(struct objectfile *obj,const char *tok,const char *tok2,int key)
{
	struct section *sect=objectfile_getsection(obj);
	if(sect)
		section_declarereference(sect,tok,key);
}


void directive_liconst(struct objectfile *obj,const char *tok,const char *tok2,int key)
{
	long v=strtol(tok,0,0);
	int chunk=count_constantchunks(v);
	printf("%d chunks\n",chunk);
	while(chunk--)
	{
		int c=(v>>(6*chunk))&0x3f;
		c|=0xc0;
		printf("Emitting chunk %d, %x\n",chunk,c);
		objectfile_emitbyte(obj,c);
	}
}


void directive_absolute(struct objectfile *obj,const char *tok,const char *tok2,int key)
{
	unsigned int val;
	if(!tok2)
		asmerror("Missing value for .abs");
	val=strtoul(tok2,0,0);
	struct section *sect=objectfile_getsection(obj);
	section_declareabsolute(sect,tok,val,0);
}


void directive_align(struct objectfile *obj,const char *tok,const char *tok2,int key)
{
	int align=atoi(tok);
	struct section *sect=objectfile_getsection(obj);
	section_align(sect,align);
}


void directive_common(struct objectfile *obj,const char *tok,const char *tok2,int key)
{
	int size=atoi(tok2);
	struct section *sect=objectfile_getsection(obj);
	section_declarecommon(sect,tok,size,key);
}


struct directive
{
	char *mnem;
	void (*handler)(struct objectfile *obj,const char *token,const char *token2,int key);
	int key;
};


struct directive directives[]=
{
	{".ctor",directive_ctordtor,SECTIONFLAG_CTOR},
	{".dtor",directive_ctordtor,SECTIONFLAG_DTOR},
	{".global",directive_sectionflags,SYMBOLFLAG_GLOBAL},
	{".globl",directive_sectionflags,SYMBOLFLAG_GLOBAL},
	{".weak",directive_sectionflags,SYMBOLFLAG_WEAK},
	{".section",directive_section,0},
	{".abs",directive_absolute,0},
	{".align",directive_align,0},
	{".comm",directive_common,1},
	{".lcomm",directive_common,0},
	{".int",directive_literal,4},
	{".short",directive_literal,2},
	{".byte",directive_literal,1},
	{".reloc",directive_reloc,0},
	{".liabs",directive_reloc,SYMBOLFLAG_LDABS},
	{".lipcrel",directive_reloc,SYMBOLFLAG_LDPCREL},
	{".liconst",directive_liconst,0},
	{0,0}
};


/* Attempt to assemble the named file.  Calls exit() on failure. */
int assemble(const char *fn,const char *on)
{
	FILE *f;
	struct objectfile *obj;

	obj=objectfile_new();
	if(!obj)
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
					directive_label(obj,tok,0,0);
				}
				else
				{
					/* Search the directives table */
					d=0;
					while(directives[d].mnem)
					{
						if(strcasecmp(tok,directives[d].mnem)==0)
						{
							directives[d].handler(obj,tok2,tok3,directives[d].key);
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
								objectfile_emitbyte(obj,opc);
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
	objectfile_output(obj,on);
	objectfile_dump(obj);
	objectfile_delete(obj);
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

