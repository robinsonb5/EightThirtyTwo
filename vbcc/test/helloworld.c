#include "uart.h"


int puts_nobyte(const char *msg)
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

int main(int argc,char **argv)
{
	puts_nobyte("\033[32mHello world!\033[0m\n");
	return(-1);
}

