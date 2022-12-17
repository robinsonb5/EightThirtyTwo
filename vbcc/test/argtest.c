#include "uart.h"
#include "stdarg.h"
#include "small_printf.h"

void regularfunc(int *p,int v)
{
	*p=v;
}

void vafunc(char *fmt,...)
{
	va_list va;
	va_start(va,fmt);	
	putchar(va_arg(va,int));
	putchar(va_arg(va,int));
	va_end(va);
}

int main(int argc,char **argv)
{
	int t;
	regularfunc(&t,0x1234);
	small_printf("%s\n","test");
	return(0);
}

