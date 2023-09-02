/*
	832ocd.c

	Copyright (c) 2020 by Alastair M. Robinson

	This file is part of the EightThirtyTwo CPU project.

	EightThirtyTwo is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	EightThirtyTwo is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with EightThirtyTwo.  If not, see <https://www.gnu.org/licenses/>.
*/

#include <ncurses.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>

#include "832ocd.h"
#include "832ocd_connection.h"
#include "frontend.h"

/* Imported from 832a */
#include "832opcodes.h"
#include "832a.h"
#include "section.h"
#include "symbol.h"
#include "mapfile.h"
#include "script.h"

#ifdef DEMIST_MSYS
WSADATA wsaDataVar; 
#endif

WINDOW *create_newwin(const char *title,int height, int width, int starty, int startx);
void decorate_window(WINDOW *win,int width,const char *title);

void destroy_win(WINDOW *local_win);


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
	char *symbolmapfn;
	enum eightthirtytwo_endian endian;
	char *uploadfile;
};



char disbuf[REGS_WIDTH];
void disassemble_byte(struct ocd_rbuf *code,unsigned char op,int addr,int row)
{
	int opc=op&0xf8;
	unsigned int j;
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

void ocd_rbuf_clear(struct ocd_rbuf *buf)
{
	if(buf)
	{
		buf->cursor=-OCD_BUFSIZE;
	}
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
		rb->uploadfile=0;
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
	int a;
	buf->cursor-=4;
	a=buf->cursor-OCD_BUFSIZE/2;
	OCD_READ(buf->con,a);
	ocd_rbuf_fillword(buf,a);
}


void ocd_rbuf_next(struct ocd_rbuf *buf)
{
	int a=buf->cursor+OCD_BUFSIZE/2;
	OCD_READ(buf->con,a);
	ocd_rbuf_fillword(buf,a);
	buf->cursor+=4;
}


void ocd_rbuf_fill(struct ocd_rbuf *buf,int addr)
{
	int i;
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
		ocd_release(code->con);
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
	ocd_release(con);
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
	char *title="Disassembly";
	struct symbol *s;
	s=section_findglobalsymbolbycursor(code->symbolmap,pc);
	if(s && (s->flags&SYMBOLFLAG_GLOBAL))
		title=s->identifier;
	werase(w);
	decorate_window(w,DIS_WIN_WIDTH,title);

	if(h>(OCD_BUFSIZE-4))
		h=(OCD_BUFSIZE-4);
	a=pc;
	for(i=0;i<h;++i)
	{
		char caret=' ';
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


void draw_help(WINDOW *w)
{
	int i=0;
	int h=LINES-REGS_HEIGHT-3;
	werase(w);
	decorate_window(w,DIS_WIN_WIDTH,"Help");

	if(h--)
		mvwprintw(w,1+i++,2,"b: Set breakpoint");
	if(h--)
		mvwprintw(w,1+i++,2,"c: Continue program - run until breakpoint");
	if(h--)
		mvwprintw(w,1+i++,2,"C: Set breakpoint at r7 + <n>, then run");
	if(h--)
		mvwprintw(w,1+i++,2,"d: Set disassembly start address to <addr>");
	if(h--)
		mvwprintw(w,1+i++,2,"   (<addr> can be a symbol in the mapfile)");
	if(h--)
		mvwprintw(w,1+i++,2,"e: Set big or little endian mode");
	if(h--)
		mvwprintw(w,1+i++,2,"s: Single step");
	if(h--)
		mvwprintw(w,1+i++,2,"S: Single step <n> times");
	if(h--)
		mvwprintw(w,1+i++,2,"r: Read word at <addr>");
	if(h--)
		mvwprintw(w,1+i++,2,"w: Write to <addr> with <value>");
	if(h--)
		mvwprintw(w,1+i++,2,"u: Upload <file> to address 0");
	if(h--)
		mvwprintw(w,1+i++,2,"U: Upload <file> to <address>");
	if(h--)
		mvwprintw(w,1+i++,2,"m: Add a memo to the messages pane");
	if(h--)
		mvwprintw(w,1+i++,2,"q: Quit");
	if(h--)
		mvwprintw(w,1+i++,2,"Scroll with cursor up/down / Page up/down");

	wrefresh(w);
}


void parse_mapfile(struct ocd_rbuf *buf)
{
	struct section *result=0;
	if(buf && buf->symbolmapfn)
	{
		result=mapfile_read(buf->symbolmapfn);
	}
	if(buf)
		buf->symbolmap=result;
}


void parse_args(int argc, char *argv[],struct ocd_rbuf *buf)
{
	int nextmap=0;
	int nextupload=0;
	int nextendian=0;
	int i;
	for(i=1;i<argc;++i)
	{
		if(strncmp(argv[i],"-m",2)==0)
			nextmap=1;
		else if(strncmp(argv[i],"-u",2)==0)
			nextupload=1;
		else if(strncmp(argv[i],"-e",2)==0)
			nextendian=1;
		else if(nextmap)
		{
			buf->symbolmapfn=argv[i];
			parse_mapfile(buf);
			nextmap=0;
		}
		else if(nextupload)
		{
			buf->uploadfile=argv[i];
			nextupload=0;
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


int main(int argc, char *argv[])
{
	int ch;
	int running=1;
	int disaddr=0;
	int uploadaddress=0;
	int pioaddress=0;
	const char *err;
	struct ocd_connection *ocdcon;
	struct ocd_rbuf *code;
	struct ocd_frontend *frontend;

#ifdef DEMIST_MSYS    
    if (WSAStartup(MAKEWORD(2, 0), &wsaDataVar) != 0)
     {
         fprintf(stderr,"WSAStartup() failed");
         exit(1);
     }
#endif

	ocdcon=ocd_connection_new();
	if(!ocdcon || (err=ocd_connect(ocdcon,OCD_ADDR,OCD_PORT)))
	{
		fprintf(stderr,"%s\nEnsure 832bridge.tcl is running under quartus_stp.\n",err);	
		return(0);
	}

	if((code=ocd_rbuf_new(ocdcon)))
	{
		if((frontend=ocd_frontend_new()))
		{
			parse_args(argc,argv,code);

			OCD_STOP(ocdcon);
			get_regfile(ocdcon,&code->regfile);
			code->regfile.prevpc=code->regfile.regs[7]-1;
			disaddr=code->regfile.regs[7];
			draw_regfile(frontend->reg_win,&code->regfile);

			/* If we have a symbolmap, set uploadaddress to the value of the "_start" symbol. */
			uploadaddress=0;
			if(code && code->symbolmap)
			{
				struct symbol *sym=section_findsymbol(code->symbolmap,"_start");
				if(sym)
					uploadaddress=sym->cursor;
			}

			move(LINES-1,2);

			while(running)
			{
				int corerunning;
				char *input;
				ocd_frontend_status(frontend,0);

				draw_disassembly(frontend->dis_win,code,disaddr);

				timeout(-1);
				ch=0;
				if(code->con->cpuconnected && code->con->bridgeconnected)
					ch = getch();

				switch(ch)
				{
					case KEY_LEFT:
						break;
					case KEY_RIGHT:
						break;
					case KEY_UP:
						--disaddr;
						break;
					case KEY_DOWN:
						++disaddr;
						break;
					case KEY_BACKSPACE: /* backspace */
						break;

					case KEY_PPAGE:
						disaddr-=DIS_WIN_HEIGHT-2;
						break;

					case KEY_NPAGE:
						disaddr+=DIS_WIN_HEIGHT-2;
						break;

					case 'c':
						OCD_RUN(code->con);
						ocd_release(code->con);
						ocd_frontend_status(frontend,"Running... (press any key to stop)");
						timeout(100);
						corerunning=1;
						while(corerunning)
						{
							if(getch()!=ERR)
							{
								OCD_STOP(code->con);
								ocd_release(code->con);
								corerunning=0;
							}
							else
							{
								/* Read the break flag */
								int f=OCD_READREG(code->con,9);
								if(f & 0x80)
									corerunning=0;
								ocd_release(code->con);
							}
						}
						get_regfile(ocdcon,&code->regfile);
						disaddr=code->regfile.prevpc=code->regfile.regs[7];
						draw_regfile(frontend->reg_win,&code->regfile);
						break;


					case 'C':
						input=frontend_getinput(frontend->cmd_win,"Run until r7 + ",10);
						if(strlen(input))
						{
							char *endptr;
							int val=strtoul(input,&endptr,0);
							if(endptr!=input)
							{
								OCD_BREAKPOINT(code->con,code->regfile.regs[7]+val);
								OCD_RUN(code->con);
								ocd_release(code->con);
								ocd_frontend_status(frontend,"Running... (press any key to stop)");
								timeout(100);
								corerunning=1;
								while(corerunning)
								{
									if(getch()!=ERR)
									{
										OCD_STOP(code->con);
										ocd_release(code->con);
										corerunning=0;
									}
									else
									{
										/* Read the break flag */
										int f=OCD_READREG(code->con,9);
										if(f & 0x80)
											corerunning=0;
										ocd_release(code->con);
									}
								}
								get_regfile(ocdcon,&code->regfile);
								disaddr=code->regfile.prevpc=code->regfile.regs[7];
								draw_regfile(frontend->reg_win,&code->regfile);
							}
						}
						break;


					case 'h':
						draw_help(frontend->dis_win);
						frontend_choice(frontend,"Press enter to continue...","\n ",' ');
						break;

					case 'e':
						ch=frontend_choice(frontend,"Set endian mode (b/l): ","bl",code->endian==EIGHTTHIRTYTWO_BIGENDIAN ? 'b' : 'l');
						if(ch=='b')
							code->endian=EIGHTTHIRTYTWO_BIGENDIAN;
						else if(ch=='l')
							code->endian=EIGHTTHIRTYTWO_LITTLEENDIAN;
						ocd_rbuf_clear(code);
						break;

					case 'q':
					case 'Q':
						ocd_frontend_status(frontend,"Really quit? ");
						if(frontend_confirm())
							running=0;
						break;

					case 'b':
						input=frontend_getinput(frontend->cmd_win,"Breakpoint address: ",16);
						if(strlen(input))
						{
							char *endptr;
							int addr=strtoul(input,&endptr,0);
							if(endptr!=input)
							{
								OCD_BREAKPOINT(code->con,addr);
								ocd_release(code->con);
								ocd_frontend_memof(frontend,"Breakpoint: %08x",addr);
							}
						}
						break;

					case 'S':
						/* Multiple steps. */
						input=frontend_getinput(frontend->cmd_win,"Multiple steps: ",10);
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
						draw_regfile(frontend->reg_win,&code->regfile);

						if(code->regfile.regs[7]<disaddr)
							disaddr=code->regfile.regs[7];
						if((code->regfile.regs[7]-disaddr)>(DIS_WIN_HEIGHT-5))
							disaddr=code->regfile.regs[7]-(DIS_WIN_HEIGHT-5);
						break;

					case 'r':
						input=frontend_getinput(frontend->cmd_win,"Read: ",16);
						if(strlen(input))
						{
							char *endptr;
							int addr=strtoul(input,&endptr,0);
							if(endptr!=input)
							{
								int v=OCD_READ(code->con,addr);
								ocd_release(code->con);
								ocd_frontend_memof(frontend,"R - %08x: %08x",addr,v);
							}
						}
						break;
					case 'R':
						break;

					case 'w':
						input=frontend_getinput(frontend->cmd_win,"Write - Address: ",16);
						if(strlen(input))
						{
							char *endptr;
							int addr=strtoul(input,&endptr,0);
							if(endptr!=input)
							{
								input=frontend_getinput(frontend->cmd_win,"Write - Value: ",16);
								if(strlen(input))
								{
									char *endptr;
									int v=strtoul(input,&endptr,0);
									if(endptr!=input)
									{
										OCD_WRITE(code->con,addr,v);
										ocd_release(code->con);
										ocd_frontend_memof(frontend,"W - %08x: %08x",addr,v);
									}
								}
							}
						}
						break;
					case 'W':
						break;

					case 'm':
						input=frontend_getinput(frontend->cmd_win,"Memo: ",0);
						if(strlen(input))
							ocd_frontend_memof(frontend,"%s",input);
						break;

					case 'd':
						input=frontend_getinput(frontend->cmd_win,"Disassembly start (address or symbol): ",0);
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
									ocd_frontend_memo(frontend,"Symbol not found");
							}
							else
								disaddr=v;
						}
						break;

					case 'U':
						input=frontend_getinput(frontend->cmd_win,"Upload Address: ",16);
						if(strlen(input))
						{
							char *endptr;
							uploadaddress=strtoul(input,&endptr,0);
							if(endptr==input)
							{
								ocd_frontend_memo(frontend,"Bad address");
								break;
							}
						}
						// Fall through to upload
					case 'u':
						input=frontend_getinput(frontend->cmd_win,"Filename (or enter): ",0);
						if(!strlen(input))
						{
							/* If no filename has been given we're probably reloading modified firmware, so reload the symbol map too... */
							if(code->symbolmap)
								section_delete(code->symbolmap);
							parse_mapfile(code);
							input=code->uploadfile;
						}
						ocd_frontend_memof(frontend,"Uploading to 0x%x...",uploadaddress);
						if(input && ocd_uploadfile(code->con,input,uploadaddress,code->endian))
							ocd_frontend_memo(frontend,"Upload succeeded");
						else					
							ocd_frontend_memo(frontend,"Upload failed");
						break;

					case 'P':
						input=frontend_getinput(frontend->cmd_win,"PIO Address: ",16);
						if(strlen(input))
						{
							char *endptr;
							pioaddress=strtoul(input,&endptr,0);
							if(endptr==input)
							{
								ocd_frontend_memo(frontend,"Bad address");
								break;
							}
						}
						// Fall through to pio
					case 'p':
						input=frontend_getinput(frontend->cmd_win,"Filename: ",0); /* FIXME - remember previous filename? */
						ocd_frontend_memof(frontend,"Sending to 0x%x...",uploadaddress);
						if(input && ocd_piofile(code->con,input,pioaddress))
							ocd_frontend_memo(frontend,"PIO succeeded");
						else					
							ocd_frontend_memo(frontend,"PIO failed");
						break;

						/* Run a script */
					case 'i':
						input=frontend_getinput(frontend->cmd_win,"Script: ",0); /* FIXME - remember previous filename) */
						ocd_frontend_memo(frontend,"Running script...");
						if(input && execute_script(frontend,code->con,input))
							ocd_frontend_memo(frontend,"Script succeeded");
						else
							ocd_frontend_memo(frontend,"Script failed");
						break;

					case 10: /* enter */
						break;

					default:
						break;
				}

				/* Deal with either socket-level or JTAG level disconnection */
				while(running && ((!code->con->cpuconnected) || (!code->con->bridgeconnected)))
				{
					clear_window(frontend->dis_win,DIS_WIN_HEIGHT,DIS_WIN_WIDTH,DIS_WIN_TITLE);
					wrefresh(frontend->dis_win);
					if(code->con->bridgeconnected)
						ch=frontend_choice(frontend,"No connection to CPU - press enter to retry or q to quit.","qQ ",' ');
					else
						ch=frontend_choice(frontend,"Connection lost - press enter to reconnect or q to quit.","qQ ",' ');
					if(ch=='q' || ch=='Q')
						running=0;
					else
					{
						err=ocd_connect(ocdcon,OCD_ADDR,OCD_PORT);
						OCD_READREG(code->con,7);
						ocd_release(code->con);
						if(code->con->cpuconnected)
						{
							disaddr=code->regfile.regs[7];
							ocd_rbuf_clear(code);
						}
					}
				}
			}
			ocd_frontend_delete(frontend);
		}
		ocd_rbuf_delete(code);
	}

#ifdef DEMIST_MSYS        
    WSACleanup(); 
#endif
    
	return 0;
}


