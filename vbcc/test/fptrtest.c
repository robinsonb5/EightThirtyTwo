#include "uart.h"

int (*fptr)(const char *msg);

int main(int argc,char **argv)
{
	int iptr;
	fptr=puts;
	iptr=(int)fptr;
	((int (*)(const char *))iptr)("Hello world!\n");
	return(0);
}

#include "uart.c"

