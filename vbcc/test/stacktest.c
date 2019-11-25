
#include "uart.h"

struct teststruct
{
	int r1;
	int r2;
	char *tmp;
}

int main(int argc,char **argv)
{
	int v1=2;
	int v2=3;
	struct teststruct ts;
	puts("Test\n");
	ts.r1=v1;
	ts.r2=v2;
	ts.tmp="Hello, world\n";
	puts(ts.tmp+ts.r1+ts.r2);
	return(0);
}

int putchar(unsigned int c)
{
	volatile int *uart=&HW_UART(REG_UART);
	do {} while(!((*uart)&(1<<REG_UART_TXREADY)));

	*uart=c;
	return(c);
}


int puts(const char *msg)
{
	unsigned char c;
	int result=0;

	while(c=*msg++)
	{
		putchar(c);
		++result;
	}
	return(result);
}

