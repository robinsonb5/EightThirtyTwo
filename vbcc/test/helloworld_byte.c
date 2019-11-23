/* Hardware registers for a supporting UART to the ZPUFlex project. */

#include "uart.h"

//int thread2main(int argc,char **argv)
//{
//}

int main(int argc,char **argv)
{
	puts("Hello world!\n");
	return(-1);
}

int putchar(int c)
{
	volatile int *uart=&HW_UART(REG_UART);
	do {} while(!((*uart)&(1<<REG_UART_TXREADY)));

	*uart=c;
	return(c);
}


int puts(const char *msg)
{
	char c;
	int result=0;

	while(c=*msg++)
	{
		putchar(c);
		++result;
	}
	return(result);
}

