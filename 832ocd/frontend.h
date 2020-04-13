#ifndef FRONTEND_H
#define FRONTEND_H

#include <ncurses.h>

int frontend_confirm();
char *frontend_getinput(WINDOW *w,const char *prompt,int base);

#endif

