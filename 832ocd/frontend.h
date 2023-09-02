#ifndef FRONTEND_H
#define FRONTEND_H

#include <ncurses.h>


#define REGS_WIDTH 48
#define REGS_HEIGHT 6

#define DIS_WIN_TITLE "Dissasembly"
#define DIS_WIN_WIDTH REGS_WIDTH
#define DIS_WIN_HEIGHT (LINES-REGS_HEIGHT-1)
#define MEM_WIN_TITLE "Messages"
#define MEM_WIN_WIDTH (COLS-REGS_WIDTH)
#define MEM_WIN_HEIGHT (LINES-1)

struct ocd_frontend
{
	WINDOW *reg_win;
	WINDOW *dis_win;
	WINDOW *mem_win;
	WINDOW *cmd_win;
};

int frontend_choice(struct ocd_frontend *ui,const char *prompt,const char *options,char def);
int frontend_confirm();
char *frontend_getinput(WINDOW *w,const char *prompt,int base);

struct ocd_frontend *ocd_frontend_new();
void ocd_frontend_delete(struct ocd_frontend *ui); 
void ocd_frontend_memof(struct ocd_frontend *ui,const char *msg,...);
void ocd_frontend_memo(struct ocd_frontend *ui,const char *msg);
void ocd_frontend_status(struct ocd_frontend *ui,const char *msg);


/* FIXME - these should be static and internal to frontend.c */
void scroll_window(WINDOW *w,int height,int width,const char *title);
void clear_window(WINDOW *w,int height,int width,const char *title);

#endif

