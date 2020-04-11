#include <ncurses.h>
#include <string.h>
#include <stdlib.h>

#include "832ocd.h"
#include "832ocd_connection.h"

WINDOW *create_newwin(const char *title,int height, int width, int starty, int startx);
void destroy_win(WINDOW *local_win);

#define REGS_WIDTH 48
#define REGS_HEIGHT 6

#define OCD_BUFSIZE 64
#define OCD_BUFMASK 63

/* Ring buffer contains 32 bytes - 8 words of program data.
   As we read each value we fill in the value 4 words ahead. */

struct ocd_rbuf
{
	int pc;
	struct ocd_connection *con;
	unsigned char buffer[OCD_BUFSIZE];
};


struct ocd_rbuf *ocd_rbuf_new(struct ocd_connection *con)
{
	struct ocd_rbuf *rb;
	rb=(struct ocd_rbuf *)malloc(sizeof(struct ocd_rbuf));
	if(rb)
	{
		rb->con=con;
		rb->pc=-OCD_BUFSIZE;
	}
	return(rb);
}


void ocd_rbuf_delete(struct ocd_rbuf *buf)
{
	if(buf)
	{
		free(buf);
	}
}


void ocd_rbuf_fetch(struct ocd_rbuf *code,int pc)
{
	int i;
	int v;
	fprintf(stderr,"In fetch\n");
	if(code)
	{
		switch(pc-code->pc)
		{
			case 0:
				break;
			case 1:
				fprintf(stderr,"Single step\n");
				code->pc=pc;
				if((pc&3)==0)	/* Have we crossed a word boundary? */
				{
					int v;
					pc&=~3;
					pc+=OCD_BUFSIZE/2;
					v=OCD_READ(code->con,pc);
					code->buffer[(pc+i)&OCD_BUFMASK]=(v>>24)&255;
					code->buffer[(pc+i+1)&OCD_BUFMASK]=(v>>16)&255;
					code->buffer[(pc+i+2)&OCD_BUFMASK]=(v>>8)&255;
					code->buffer[(pc+i+3)&OCD_BUFMASK]=v&255;
				}
				fprintf(stderr,"done\n");
				break;
			default:
				code->pc=pc;
				pc&=~3;
				fprintf(stderr,"Filling buffer\n");
				for(i=0;i<OCD_BUFSIZE/2;i+=4)
				{
					v=OCD_READ(code->con,pc+i);
					code->buffer[(pc+i)&OCD_BUFMASK]=(v>>24)&255;
					code->buffer[(pc+i+1)&OCD_BUFMASK]=(v>>16)&255;
					code->buffer[(pc+i+2)&OCD_BUFMASK]=(v>>8)&255;
					code->buffer[(pc+i+3)&OCD_BUFMASK]=v&255;
				}
				fprintf(stderr,"Clearing remainder\n");
				for(i=OCD_BUFSIZE/2;i<OCD_BUFSIZE;++i)
				{
					code->buffer[(pc+i)&OCD_BUFMASK]=0;
				}
				fprintf(stderr,"Single step\n");
		}
		fprintf(stderr,"Releasing connection\n");
		OCD_RELEASE(code->con);
		fprintf(stderr,"done\n");
	}
}


int ocd_rbuf_get(struct ocd_rbuf *code,int pc)
{
	fprintf(stderr,"Getting opcode at %x\n",pc);
	if(code)
	{
		int i;
		if((pc-code->pc)>(OCD_BUFSIZE/2))
		{
			fprintf(stderr,"Address not in buffer - fetching\n");
			ocd_rbuf_fetch(code,pc);
			fprintf(stderr,"Done\n");
		}
		return(code->buffer[pc&OCD_BUFMASK]);
	}
	return(0);
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
	int h=LINES-REGS_HEIGHT-3;
	if(h>(OCD_BUFSIZE-4))
		h=(OCD_BUFSIZE-4);
	for(i=0;i<h;++i)
	{
		mvwprintw(w,1+i,2,"%08x: %02x",pc+i,ocd_rbuf_get(code,pc+i));
	}
	wrefresh(w);
}


int confirm()
{
	while(1)
	{
		char ch = getch();
		switch(ch)
		{
			case 'y':
			case 'Y':
				return(1);
				break;
			case 'n':
			case 'N':
			case 27:
				return(0);
				break;
			default:
				break;
		}
	}
}


int main(int argc, char *argv[])
{
	int x, y;
	int ch;
	int running=1;
	struct ocd_connection *ocdcon;
	struct regfile regs;
	struct ocd_rbuf *code;
	WINDOW *reg_win;
	WINDOW *dis_win;
	WINDOW *stack_win;
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
	dis_win=create_newwin("Disassembly",LINES-REGS_HEIGHT-1,REGS_WIDTH,REGS_HEIGHT,0);
	stack_win=create_newwin("Stack",LINES/2-1,COLS-REGS_WIDTH,0,REGS_WIDTH);
	mem_win=create_newwin("Memory",LINES-LINES/2,COLS-REGS_WIDTH,LINES/2-1,REGS_WIDTH);
	cmd_win=newwin(1,COLS,LINES-1,0);

	get_regfile(ocdcon,&regs);
	draw_regfile(reg_win,&regs);
//	ocd_rbuf_fetch(code,regs.regs[7]);
	draw_disassembly(dis_win,code,regs.regs[7]);

	move(LINES-1,2);

	while(running)
	{
		mvwprintw(cmd_win,0,0,"                ");
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
				break;
			case KEY_DOWN:
				fprintf(stderr,"key down - fetch\n");
				ocd_rbuf_fetch(code,++regs.regs[7]);
				fprintf(stderr,"key down - update\n");
				draw_disassembly(dis_win,code,regs.regs[7]);
				fprintf(stderr,"key down - done\n");
				break;
			case KEY_BACKSPACE: /* backspace */
				break;

			case 'q':
			case 'Q':
				mvwprintw(cmd_win,0,0,"Really quit? ");
				wrefresh(cmd_win);
				curs_set(2);
				if(confirm())
					running=0;
				break;

			case 's':
			case 'S':
				fprintf(stderr,"Single stepping\n");
				OCD_SINGLESTEP(ocdcon);
				fprintf(stderr,"Done\n");
				get_regfile(ocdcon,&regs);
				fprintf(stderr,"Fetching based on new r7 %x\n",regs.regs[7]);
				ocd_rbuf_fetch(code,regs.regs[7]);
				draw_regfile(reg_win,&regs);
				draw_disassembly(dis_win,code,regs.regs[7]);
				break;
			case 'r':
			case 'R':
			case 'w':
			case 'W':
				mvwprintw(cmd_win,0,0,"%c: ",ch);
				wrefresh(cmd_win);
				curs_set(2);
				break;

			case 10: /* enter */
				move(LINES-1,2);
				break;

			default:
				break;
		}
	}
	delwin(reg_win);
	delwin(dis_win);
	delwin(stack_win);
	delwin(mem_win);
	endwin();			/* End curses mode		  */

	if(code)
		ocd_rbuf_delete(code);
	
	return 0;
}

WINDOW *create_newwin(const char *title,int height, int width, int starty, int startx)
{
	WINDOW *local_win;

	local_win = newwin(height, width, starty, startx);
	box(local_win, 0 , 0);
	mvwprintw(local_win,0,(width-(2+strlen(title)))/2," %s ",title);
	wrefresh(local_win);

	return local_win;
}

