#include <stdio.h>
#include <string.h>
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


static char stringbuf[128];

char *frontend_getstring()
{
	return(&stringbuf[0]);
}

static int validatenumeric(int ch,int base)
{
	switch(base)
	{
		case 10:
			if(ch>='0' && ch<='9')
				return(1);
			break;
		case 16:
			if((ch>='0' && ch<='9') || (ch>='A' && ch<='F') || (ch>='a' && ch<='f'))
				return(1);
			break;
		default:
			return(0);
			break;
	}
	return(0);
}


char *frontend_getnumber(WINDOW *win,const char *prompt,int base)
{
	int cursor;
	int promptlen=strlen(prompt);
	int prefixbytes=0;
	werase(win);
	mvwprintw(win,0,0,prompt);
	if(!stringbuf[0])
		stringbuf[0]=' ';

	if(base==16)
	{
		stringbuf[1]='0';
		stringbuf[2]='x';
		stringbuf[3]=0;
	}
	else
	{
		stringbuf[1]=0;
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
		if(ch=='-')
			stringbuf[0]=stringbuf[0]==' ' ? '-' : ' ';
		else if(ch=='+')
			stringbuf[0]=' ';
		else if(validatenumeric(ch,base))
		{
			stringbuf[cursor++]=ch;
			stringbuf[cursor]=0;
		}
		else
		{
			switch(ch)
			{
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
					break;
			}
		}
	}
}

