#ifndef UTIL832_H
#define UTIL832_H

void setdebuglevel(int level);
int getdebuglevel();
void debug(int level,const char *fmt,...);
void hexdump(int level,char *p,int l);

void error_setfile(const char *fn);
void error_setline(int line);
void asmerror(const char *err);
void linkerror(const char *err);

void write_int_le(int i,FILE *f);
void write_short_le(int i,FILE *f);
void write_lstr(const char *str,FILE *f);

int read_int_le(FILE *f);
int read_short_le(FILE *f);
void read_lstr(FILE *f,char *ptr);

int count_constantchunks(long v);

char *strtok_escaped(char *str);
void parseescapes(char *str);


#endif

