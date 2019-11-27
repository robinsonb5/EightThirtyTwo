#include "uart.h"
#include "stdarg.h"
#include "small_printf.h"

int _cvt(int val, char *buf, int radix);

char buf[16];

int main(int argc,char **argv)
{
	int a=512;
	int	b=10;
	small_printf("T: %s, %c, %d, %d\n","Testing",65,a/b,a%b);
	small_printf("X: %x\n",0x42);
	return(0);
}

