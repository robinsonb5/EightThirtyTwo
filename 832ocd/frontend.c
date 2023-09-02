/*
	frontend.c

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

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <ncurses.h>
#include "frontend.h"


int frontend_confirm()
{
	curs_set(2);
	while(1)
	{
		char ch = getch();
		switch(ch)
		{
			case 'y':
			case 'Y':
				curs_set(0);
				return(1);
				break;
			case 'n':
			case 'N':
			case 27:
				curs_set(0);
				return(0);
				break;
			default:
				break;
		}
	}
}


char validatechar(char in,const char *options)
{
	int l;
	int i;
	if(!options)
		return(in);
	l=strlen(options);

	for(i=0;i<l;++i)
	{
		if(options[i]==in)
			return(in);
	}
	return(0);
}


#define STRINGBUFSIZE 29
static char stringbuf[STRINGBUFSIZE];

char *frontend_getinput(WINDOW *win,const char *prompt,int base)
{
	char *validkeys;
	int cursor;
	int promptlen=strlen(prompt);
	int prefixbytes=0;
	werase(win);
	mvwprintw(win,0,0,prompt);
	stringbuf[0]=' ';

	if(base==16)
	{
		stringbuf[1]='0';
		stringbuf[2]='x';
		stringbuf[3]=0;
		validkeys="abcdefABCDEF0123456789";
	}
	else if(base==10)
	{
		stringbuf[1]=0;
		validkeys="0123456789";
	}
	else
	{
		stringbuf[0]=0;
		validkeys=0;
	}
	
	cursor=prefixbytes=strlen(stringbuf);
	curs_set(2);

	while(1)
	{
		int ch;
		mvwprintw(win,0,promptlen,"%s ",stringbuf);
		wmove(win,0,promptlen+cursor);
		wrefresh(win);
		ch = getch();
		switch(ch)
		{
			case '-':
				stringbuf[0]=stringbuf[0]==' ' ? '-' : ' ';
				break;
			case '+':
				stringbuf[0]=' ';
				break;
			case KEY_BACKSPACE:
				if(cursor>prefixbytes)
					stringbuf[--cursor]=0;
				else
					stringbuf[0]=' ';
				break;
			case 27:
				stringbuf[0]=0;
				curs_set(0);
				return(stringbuf);
				break;
			case 10:
				curs_set(0);
				return(stringbuf);
				break;
			default:
				if(validatechar(ch,validkeys))
				{
					stringbuf[cursor++]=ch;
					stringbuf[cursor]=0;
				}
				break;
		}
		if(cursor>=(STRINGBUFSIZE-1))
			cursor=STRINGBUFSIZE-2;
	}
}


int frontend_choice(struct ocd_frontend *ui,const char *prompt,const char *options,char def)
{
	int promptlen=strlen(prompt);
	werase(ui->cmd_win);
	mvwprintw(ui->cmd_win,0,0,prompt);
	stringbuf[0]=def;
	stringbuf[1]=0;
	curs_set(2);
	while(1)
	{
		int ch;
		mvwprintw(ui->cmd_win,0,promptlen,"%s ",stringbuf);
		wmove(ui->cmd_win,0,promptlen);
		wrefresh(ui->cmd_win);

		ch=getch();
		if(ch==10 || ch==27)
			return(stringbuf[0]);
		else if(validatechar(ch,options))
		{
			stringbuf[0]=ch;
			return(stringbuf[0]);
		}
	}
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


struct ocd_frontend *ocd_frontend_new()
{
	struct ocd_frontend *ui=0;
	ui=(struct ocd_frontend *)malloc(sizeof(struct ocd_frontend));
	if(ui)
	{
		initscr();			/* Start curses mode 		*/
		cbreak();			/* Capture input directly	*/
		keypad(stdscr, TRUE);
		noecho();

		refresh();
		ui->reg_win=create_newwin("Register File",REGS_HEIGHT,REGS_WIDTH,0,0);
		ui->dis_win=create_newwin(DIS_WIN_TITLE,DIS_WIN_HEIGHT,DIS_WIN_WIDTH,REGS_HEIGHT,0);
		ui->mem_win=create_newwin(MEM_WIN_TITLE,MEM_WIN_HEIGHT,MEM_WIN_WIDTH,0,REGS_WIDTH);
		scrollok(ui->mem_win,1);
		ui->cmd_win=newwin(1,COLS,LINES-1,0);	
	}
	return(ui);
}


void ocd_frontend_delete(struct ocd_frontend *ui)
{
	if(ui)
	{

		delwin(ui->reg_win);
		delwin(ui->dis_win);
		delwin(ui->mem_win);
		endwin();			/* End curses mode		  */	
		free(ui);
	}
}


void scroll_window(WINDOW *w,int height,int width,const char *title)
{
	wmove(w,height-1,0);
	wclrtoeol(w);
	wscrl(w,1);
	decorate_window(w,width,title);
}


void clear_window(WINDOW *w,int height,int width,const char *title)
{
	werase(w);
	decorate_window(w,width,title);
}


void ocd_frontend_memo(struct ocd_frontend *ui,const char *msg)
{
	if(ui && msg)
	{
		scroll_window(ui->mem_win,MEM_WIN_HEIGHT,MEM_WIN_WIDTH,MEM_WIN_TITLE);
		mvwprintw(ui->mem_win,MEM_WIN_HEIGHT-2,2,msg);
		wrefresh(ui->mem_win);
	}
}

void ocd_frontend_memof(struct ocd_frontend *ui,const char *fmt,...)
{
	char buf[MEM_WIN_WIDTH+1];
	va_list args;
	va_start(args, fmt);
	vsnprintf(buf, MEM_WIN_WIDTH,fmt, args);
	va_end(args);
	ocd_frontend_memo(ui,buf);
}

void ocd_frontend_status(struct ocd_frontend *ui,const char *msg)
{
	if(msg)
		mvwprintw(ui->cmd_win,0,0,msg);
	else
	{
		werase(ui->cmd_win);
		curs_set(0);
	}
	wrefresh(ui->cmd_win);
}


