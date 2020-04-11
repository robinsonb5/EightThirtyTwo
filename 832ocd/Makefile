CC=gcc
LD=gcc
CFLAGS=-I../832a/
LIBS=-lncurses

all: 832ocd

832ocd: 832ocd.c 832ocd_connection.c ../832a/832defs.c
	$(CC) $(CFLAGS) -o $@ $+ $(LIBS) 

