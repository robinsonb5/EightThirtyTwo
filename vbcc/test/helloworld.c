/* Hardware registers for a supporting UART to the ZPUFlex project. */

#include "uart.h"

int thread2main(int argc,char **argv)
{
}

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
	int c;
	int result=0;
	int *s2=(int*)msg;

	while(1)
	{
		int i;
		int cs=*s2++;
		for(i=0;i<4;++i)
		{
			c=cs&0xff;
			cs>>=8;
			if(c==0)
				return(result);
			putchar(c);
			++result;
		}
	}
	return(result);
}

