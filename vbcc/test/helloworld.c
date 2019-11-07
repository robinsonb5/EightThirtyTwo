/* Hardware registers for a supporting UART to the ZPUFlex project. */

#include "uart.h"

int main(int argc,char **argv)
{
	puts("Hello world!\n");
	return(-1);
}

int putchar(int c)
{
	volatile int *uart=&HW_UART(REG_UART);
	while(!((*uart)&(1<<REG_UART_TXREADY)))
		;
	*uart=c;
//	while(!(HW_UART(REG_UART)&(1<<REG_UART_TXREADY)))
//		;
//	HW_UART(REG_UART)=c;
	return(c);
}


int puts(const char *msg)
{
	int c;
	int result=0;
	int *s2=(int*)msg;

	do
	{
		int i;
		int cs=*s2++;
		for(i=0;i<4;++i)
		{
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
			c=cs&0xff;
			cs>>=8;
#else
			c=(cs>>24)&0xff;
			cs<<=8;
#endif
			if(c==0)
				return(result);
			putchar(c);
			++result;
		}
	}
	while(c);
	return(result);
}

