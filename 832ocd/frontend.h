#ifndef FRONTEND_H
#define FRONTEND_H

#include <ncurses.h>

int frontend_confirm();
char *frontend_getnumber(WINDOW *w,const char *prompt,int base);
char *frontend_gethexnumber(WINDOW *w,const char *prompt);
char *frontend_getstring();

#endif

