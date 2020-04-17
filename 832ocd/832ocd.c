#include <ncurses.h>
#include <string.h>
#include <stdlib.h>

#include "832ocd.h"
#include "832ocd_connection.h"
#include "frontend.h"

/* Imported from 832a */
#include "832opcodes.h"
#include "832a.h"
#include "section.h"
#include "symbol.h"


WINDOW *create_newwin(const char *title,int height, int width, int starty, int startx);
void decorate_window(WINDOW *win,int width,const char *title);

void destroy_win(WINDOW *local_win);

#define REGS_WIDTH 48
#define REGS_HEIGHT 6

#define OCD_BUFSIZE 64
#define OCD_BUFMASK 63


/* Ring buffer contains OCD_BUFSIZE bytes of program data.
   As we read each value we fill in the value 4 words ahead. */

struct ocd_rbuf
{
	int cursor;	/* Centre point of the buffer */
	struct ocd_connection *con;
	struct regfile regfile;
	unsigned char buffer[OCD_BUFSIZE];
	struct section *symbolmap;
	enum eightthirtytwo_endian endian;
};



char disbuf[REGS_WIDTH];
void disassemble_byte(struct ocd_rbuf *code,unsigned char op,int addr,int row)
{
	FILE *f;
	int opc=op&0xf8;
	int opr=op&7;
	int j;
	static int immstreak=0;
	static int imm;
	static int signedimm=0;
	struct symbol *s;

	if(row==0)
		immstreak=0;
	if((opc&0xc0)==0xc0)
	{
		if(immstreak)
			imm<<=6;
		else
			imm=op&0x20 ? 0xffffffc0 : 0;
		imm|=op&0x3f;
		if(imm&0x80000000)
		{
			signedimm=~imm;
			signedimm+=1;
			signedimm=-signedimm;
		}
		else
			signedimm=imm;
		s=section_findsymbolbycursor(code->symbolmap,imm);
		if(s && s->cursor==imm)
			snprintf(disbuf,32,"%02x  li  %x  (%s)",op,op&0x3f,s->identifier);
		else
			snprintf(disbuf,32,"%02x  li  %x  (0x%x, %d)",op,op&0x3f,imm,signedimm);
		immstreak=1;
	}
	else
	{
		int found=0;
		/* Look for overloads first... */
		if((op&7)==7)
		{
			for(j=0;j<sizeof(opcodes)/sizeof(struct opcode);++j)
			{
				if(opcodes[j].opcode==op)
				{
					found=1;
					snprintf(disbuf,32,"%02x  %s",op,opcodes[j].mnem);
					break;
				}
			}
		}
		if(!found)
		{
			/* If not found, look for base opcodes... */
			for(j=0;j<sizeof(opcodes)/sizeof(struct opcode);++j)
			{
				if(opcodes[j].opcode==opc)
				{
					if((op==(opc_add+7) || op==(opc_addt+7)) && immstreak)
					{
						int target=addr+imm+1;
						s=section_findsymbolbycursor(code->symbolmap,target);
						if(s && s->cursor==target)
						{
							snprintf(disbuf,32,"%02x  %s  %s (%s)",
								op,opcodes[j].mnem,operands[(op&7)|((op&0xf8)==0 ? 8 : 0)].mnem,s->identifier);
						}
						else
						{
							snprintf(disbuf,32,"%02x  %s  %s (pc+%x)",
								op,opcodes[j].mnem,operands[(op&7)|((op&0xf8)==0 ? 8 : 0)].mnem,1+signedimm);
						}
					}
					else
						snprintf(disbuf,32,"%02x  %s  %s",op,opcodes[j].mnem,operands[(op&7)|((op&0xf8)==0 ? 8 : 0)].mnem);
//					if(c==(opc_ldinc+7))
//					{
//						int v=read_int(f,endian);
//						printf("\t\t0x%x\n",v);
//						a+=4;
//					}
					break;
				}
			}
		}
		immstreak=0;
	}
}


static int ocd_rbuf_high(struct ocd_rbuf *buf)
{
	return(buf->cursor+OCD_BUFSIZE/2-1);
}


static int ocd_rbuf_low(struct ocd_rbuf *buf)
{
	return(buf->cursor-OCD_BUFSIZE/2);
}


struct ocd_rbuf *ocd_rbuf_new(struct ocd_connection *con)
{
	struct ocd_rbuf *rb;
	rb=(struct ocd_rbuf *)malloc(sizeof(struct ocd_rbuf));
	if(rb)
	{
		rb->con=con;
		rb->cursor=-OCD_BUFSIZE;
		rb->symbolmap=0;
		rb->endian=EIGHTTHIRTYTWO_LITTLEENDIAN;
	}
	return(rb);
}


void ocd_rbuf_delete(struct ocd_rbuf *buf)
{
	if(buf)
	{
		if(buf->symbolmap)
			section_delete(buf->symbolmap);
		free(buf);
	}
}


void ocd_rbuf_fillword(struct ocd_rbuf *buf,int a)
{
	int v=OCD_READ(buf->con,a);
	if(buf->endian==EIGHTTHIRTYTWO_LITTLEENDIAN)
	{
		buf->buffer[(a+3)&OCD_BUFMASK]=(v>>24)&255;
		buf->buffer[(a+2)&OCD_BUFMASK]=(v>>16)&255;
		buf->buffer[(a+1)&OCD_BUFMASK]=(v>>8)&255;
		buf->buffer[(a+0)&OCD_BUFMASK]=v&255;
	}
	else
	{
		buf->buffer[(a+0)&OCD_BUFMASK]=(v>>24)&255;
		buf->buffer[(a+1)&OCD_BUFMASK]=(v>>16)&255;
		buf->buffer[(a+2)&OCD_BUFMASK]=(v>>8)&255;
		buf->buffer[(a+3)&OCD_BUFMASK]=v&255;
	}
}


void ocd_rbuf_prev(struct ocd_rbuf *buf)
{
	int a,v;
	buf->cursor-=4;
	a=buf->cursor-OCD_BUFSIZE/2;
	v=OCD_READ(buf->con,a);
	ocd_rbuf_fillword(buf,a);
}


void ocd_rbuf_next(struct ocd_rbuf *buf)
{
	int a=buf->cursor+OCD_BUFSIZE/2;
	int v=OCD_READ(buf->con,a);
	ocd_rbuf_fillword(buf,a);
	buf->cursor+=4;
}


void ocd_rbuf_fill(struct ocd_rbuf *buf,int addr)
{
	int i;
	int v;
	addr&=~3;
	if(addr<OCD_BUFSIZE/2)
		addr=OCD_BUFSIZE/2;

	for(i=-OCD_BUFSIZE/2;i<OCD_BUFSIZE/2;i+=4)
		ocd_rbuf_fillword(buf,addr+i);
	buf->cursor=addr;
}


int ocd_rbuf_get(struct ocd_rbuf *code,int addr)
{
	int high,low;
	high=ocd_rbuf_high(code);
	low=ocd_rbuf_low(code);

	if(addr<low || addr>high)
	{
		if(addr<low)
		{
			int d=low-addr;
			if(d<OCD_BUFSIZE/2)
			{
				while(d>0)
				{
					ocd_rbuf_prev(code);
					d-=4;
				}
			}
			else
				ocd_rbuf_fill(code,addr);
		}
		else
		{
			int d=addr-high;
			if(d<OCD_BUFSIZE/2)
			{
				while(d>0)
				{
					ocd_rbuf_next(code);
					d-=4;
				}
			}
			else
				ocd_rbuf_fill(code,addr);
		}
		OCD_RELEASE(code->con);
	}
	return(code->buffer[addr&OCD_BUFMASK]);
}


void get_regfile(struct ocd_connection *con,struct regfile *rf)
{
	int i;
	for(i=0;i<8;++i)
	{
		rf->regs[i]=OCD_READREG(con,i);
	}
	i=OCD_READREG(con,REG_FLAGS);
	rf->tmp=OCD_READREG(con,REG_TMP);
	OCD_RELEASE(con);
	rf->z=i&1;
	rf->c=(i>>1)&1;
	rf->cond=(i>>2)&1;
	rf->sign=(i>>3)&1;
}


void draw_regfile(WINDOW *w,struct regfile *rf)
{
	int i;
	for(i=0;i<8;++i)
	{
		mvwprintw(w,1+(i&3),2+(i>>2)*15,"r%d: %08x",i,rf->regs[i]);
	}
	mvwprintw(w,1,32,"tmp: %08x",rf->tmp);
	mvwprintw(w,2,32,"z: %d  sign: %d",rf->z&1,rf->sign&1);
	mvwprintw(w,3,32,"c: %d  cond: %d",rf->c&1,rf->cond&1);
	wrefresh(w);
}


void draw_disassembly(WINDOW *w,struct ocd_rbuf *code,int pc)
{
	int i;
	int a;
	int h=LINES-REGS_HEIGHT-3;

	if(h>(OCD_BUFSIZE-4))
		h=(OCD_BUFSIZE-4);
	a=pc;
	for(i=0;i<h;++i)
	{
		char caret=' ';
		struct symbol *s;
		mvwprintw(w,1+i,2,"                                          ");
		s=section_findsymbolbycursor(code->symbolmap,a);
		if(s && s->cursor==a)
		{
			mvwprintw(w,1+i,2,"%s:",s->identifier);
			++i;
		}
		if(i<h)
		{
			if(a==code->regfile.regs[7])
				caret='~';
			if(a==code->regfile.prevpc)
				caret='>';
			disassemble_byte(code,ocd_rbuf_get(code,a),a,a-pc);
			mvwprintw(w,1+i,2,"%c %08x: %s",caret,a,disbuf);
			++a;
		}
	}
	wrefresh(w);
}


struct section *parse_mapfile(const char *filename)
{
	struct section *result=0;
	if(filename)
	{
		FILE *f;
		f=fopen(filename,"r");
		if(f)
		{
			if(result=section_new(0,"symboltable"))
			{
				int line=0;
				char *linebuf=0;
				size_t len;
				int c;
				while(c=getline(&linebuf,&len,f)>0)
				{
					char *endptr;
					int v=strtoul(linebuf,&endptr,0);
					if(!v && endptr==linebuf)
						linkerror("Invalid constant value");
					else
					{
						if(endptr[1]==' ')
						{
							struct symbol *sym;
							char *tok=strtok_escaped(endptr);
							if(sym=symbol_new(tok,v,0))
								section_addsymbol(result,sym);
						}
					}					
				}
			}
			fclose(f);
		}	
	}

	return(result);
}


void parse_args(int argc, char *argv[],struct ocd_rbuf *buf)
{
	int nextmap=0;
	int nextendian=0;
	int i;
	for(i=1;i<argc;++i)
	{
		if(strncmp(argv[i],"-m",2)==0)
			nextmap=1;
		else if(strncmp(argv[i],"-e",2)==0)
			nextendian=1;
		else if(nextmap)
		{
			buf->symbolmap=parse_mapfile(argv[i]);
			nextmap=0;
		}
		else if(nextendian)
		{
			if(*argv[i]=='l')
				buf->endian=EIGHTTHIRTYTWO_LITTLEENDIAN;
			else if(*argv[i]=='b')
				buf->endian=EIGHTTHIRTYTWO_BIGENDIAN;
			else
				linkerror("Endian flag must be \"little\" or \"big\"\n");
			nextendian=0;
		}

		/* Dirty trick for when we have an option with no space before the parameter. */
		if((*argv[i]=='-') && (strlen(argv[i])>2))
		{
			argv[i]+=2;
			if(*argv[i]=='=')
				++argv[i];
			--i;
		}
	}
}


#define DIS_WIN_HEIGHT (LINES-REGS_HEIGHT-1)
#define MEM_WIN_TITLE "Messages"
#define MEM_WIN_WIDTH (COLS-REGS_WIDTH)
#define MEM_WIN_HEIGHT (LINES-1)
// #define MEM_WIN_HEIGHT (LINES-LINES/2)

int scroll_window(WINDOW *w,int height,int width,const char *title)
{
	wmove(w,height-1,0);
	wclrtoeol(w);
	wscrl(w,1);
	decorate_window(w,width,title);
}

int main(int argc, char *argv[])
{
	int x, y;
	int ch;
	int running=1;
	int disaddr=0;
	struct ocd_connection *ocdcon;
	struct ocd_rbuf *code;
	WINDOW *reg_win;
	WINDOW *dis_win;
//	WINDOW *stack_win;
	WINDOW *mem_win;
	WINDOW *cmd_win;

	ocdcon=ocd_connection_new();
	if(!ocd_connect(ocdcon,OCD_ADDR,OCD_PORT))
		return(0);

	code=ocd_rbuf_new(ocdcon);

	initscr();			/* Start curses mode 		*/
	cbreak();			/* Capture input directly	*/
	keypad(stdscr, TRUE);
	noecho();

	refresh();
	reg_win=create_newwin("Register File",REGS_HEIGHT,REGS_WIDTH,0,0);
	dis_win=create_newwin("Disassembly",DIS_WIN_HEIGHT,REGS_WIDTH,REGS_HEIGHT,0);
//	stack_win=create_newwin("Stack",LINES/2-1,COLS-REGS_WIDTH,0,REGS_WIDTH);
	mem_win=create_newwin(MEM_WIN_TITLE,MEM_WIN_HEIGHT,MEM_WIN_WIDTH,0,REGS_WIDTH);
	scrollok(mem_win,1);
	cmd_win=newwin(1,COLS,LINES-1,0);

	parse_args(argc,argv,code);

	OCD_STOP(ocdcon);
	get_regfile(ocdcon,&code->regfile);
	code->regfile.prevpc=code->regfile.regs[7]-1;
	draw_regfile(reg_win,&code->regfile);
	draw_disassembly(dis_win,code,disaddr);

	move(LINES-1,2);

	while(running)
	{
		int corerunning;
		char *input;
		werase(cmd_win);
		curs_set(0);
		wrefresh(cmd_win);

		ch = getch();
		switch(ch)
		{
			case KEY_LEFT:
				break;
			case KEY_RIGHT:
				break;
			case KEY_UP:
				--disaddr;
				draw_disassembly(dis_win,code,disaddr);
				break;
			case KEY_DOWN:
				++disaddr;
				draw_disassembly(dis_win,code,disaddr);
				break;
			case KEY_BACKSPACE: /* backspace */
				break;

			case KEY_PPAGE:
				disaddr-=DIS_WIN_HEIGHT-2;
				draw_disassembly(dis_win,code,disaddr);
				break;

			case KEY_NPAGE:
				disaddr+=DIS_WIN_HEIGHT-2;
				draw_disassembly(dis_win,code,disaddr);
				break;

			case 'c':
				OCD_RUN(code->con);
				OCD_RELEASE(code->con);
				mvwprintw(cmd_win,0,0,"Running... (press any key to stop)");
				wrefresh(cmd_win);
				timeout(100);
				corerunning=1;
				while(corerunning)
				{
					if(getch()!=ERR)
					{
						OCD_STOP(code->con);
						OCD_RELEASE(code->con);
						corerunning=0;
					}
					else
					{
						/* Read the break flag */
						int f=OCD_READREG(code->con,9);
						if(f & 0x80)
							corerunning=0;
						OCD_RELEASE(code->con);
					}
				}
				get_regfile(ocdcon,&code->regfile);
				disaddr=code->regfile.prevpc=code->regfile.regs[7];
				draw_regfile(reg_win,&code->regfile);
				draw_disassembly(dis_win,code,disaddr);
				break;

			case 'q':
			case 'Q':
				mvwprintw(cmd_win,0,0,"Really quit? ");
				wrefresh(cmd_win);
				if(frontend_confirm())
					running=0;
				break;

			case 'b':
				input=frontend_getinput(cmd_win,"Breakpoint address: ",16);
				if(strlen(input))
				{
					char *endptr;
					int addr=strtoul(input,&endptr,0);
					if(endptr!=input)
					{
						int v=OCD_BREAKPOINT(code->con,addr);
						OCD_RELEASE(code->con);
						scroll_window(mem_win,MEM_WIN_HEIGHT,MEM_WIN_WIDTH,MEM_WIN_TITLE);
						mvwprintw(mem_win,MEM_WIN_HEIGHT-2,2,"Breakpoint: %08x",addr);
						wrefresh(mem_win);
					}
				}
				break;

			case 'S':
				/* Multiple steps. */
				input=frontend_getinput(cmd_win,"Multiple steps: ",10);
				if(strlen(input))
				{
					char *endptr;
					int i=strtoul(input,&endptr,0);
					if(endptr!=input)
					{
						while(--i>0)
							OCD_SINGLESTEP(ocdcon);						
					}
				}
				else
					break;
				code->regfile.regs[7]=OCD_READREG(ocdcon,7);
				/* Fall through to single step */
			case 's':
				OCD_SINGLESTEP(ocdcon);
				code->regfile.prevpc=code->regfile.regs[7];
				get_regfile(ocdcon,&code->regfile);
				draw_regfile(reg_win,&code->regfile);

				if(code->regfile.regs[7]<disaddr)
					disaddr=code->regfile.regs[7];
				if((code->regfile.regs[7]-disaddr)>(DIS_WIN_HEIGHT-5))
					disaddr=code->regfile.regs[7]-(DIS_WIN_HEIGHT-5);
				draw_disassembly(dis_win,code,disaddr);
				break;
			case 'r':
				input=frontend_getinput(cmd_win,"Read: ",16);
				if(strlen(input))
				{
					char *endptr;
					int addr=strtoul(input,&endptr,0);
					if(endptr!=input)
					{
						int v=OCD_READ(code->con,addr);
						OCD_RELEASE(code->con);
						scroll_window(mem_win,MEM_WIN_HEIGHT,MEM_WIN_WIDTH,MEM_WIN_TITLE);
						mvwprintw(mem_win,MEM_WIN_HEIGHT-2,2,"R - %08x: %08x",addr,v);
						wrefresh(mem_win);
					}
				}
				break;
			case 'R':
				break;
			case 'w':
				input=frontend_getinput(cmd_win,"Write - Address: ",16);
				if(strlen(input))
				{
					char *endptr;
					int addr=strtoul(input,&endptr,0);
					if(endptr!=input)
					{
						input=frontend_getinput(cmd_win,"Write - Value: ",16);
						if(strlen(input))
						{
							char *endptr;
							int v=strtoul(input,&endptr,0);
							if(endptr!=input)
							{
								OCD_WRITE(code->con,addr,v);
								OCD_RELEASE(code->con);
								scroll_window(mem_win,MEM_WIN_HEIGHT,MEM_WIN_WIDTH,MEM_WIN_TITLE);
								mvwprintw(mem_win,MEM_WIN_HEIGHT-2,2,"W - %08x: %08x",addr,v);
								wrefresh(mem_win);
							}
						}
					}
				}
				break;
			case 'W':
				break;

			case 'm':
				input=frontend_getinput(cmd_win,"Memo: ",0);
				if(strlen(input))
				{
					scroll_window(mem_win,MEM_WIN_HEIGHT,MEM_WIN_WIDTH,MEM_WIN_TITLE);
					mvwprintw(mem_win,MEM_WIN_HEIGHT-2,2,"%s",input);
					wrefresh(mem_win);
				}
				break;

			case 'd':
				input=frontend_getinput(cmd_win,"Disassembly start (address or symbol): ",0);
				if(strlen(input))
				{
					char *endptr;
					int v=strtoul(input,&endptr,0);
					if(endptr==input)
					{
						struct symbol *sym=section_findsymbol(code->symbolmap,input);
						if(sym)
						{
							v=sym->cursor;
							disaddr=v;
						}
						else
						{
							scroll_window(mem_win,MEM_WIN_HEIGHT,MEM_WIN_WIDTH,MEM_WIN_TITLE);
							mvwprintw(mem_win,MEM_WIN_HEIGHT-2,2,"Symbol not found");
							wrefresh(mem_win);
						}
					}
					else
					{
						disaddr=v;
					}
					draw_disassembly(dis_win,code,disaddr);
				}
				break;

			case 10: /* enter */
				break;

			default:
				break;
		}
	}
	delwin(reg_win);
	delwin(dis_win);
//	delwin(stack_win);
	delwin(mem_win);
	endwin();			/* End curses mode		  */

	if(code)
		ocd_rbuf_delete(code);
	
	return 0;
}


void decorate_window(WINDOW *win,int width,const char *title)
{
	box(win, 0 , 0);
	mvwprintw(win,0,(width-(2+strlen(title)))/2," %s ",title);
}


WINDOW *create_newwin(const char *title,int height, int width, int starty, int startx)
{
	WINDOW *local_win;

	local_win = newwin(height, width, starty, startx);
	decorate_window(local_win,width,title);
	wrefresh(local_win);

	return local_win;
}

