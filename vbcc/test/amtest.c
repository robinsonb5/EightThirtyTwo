/* Hardware registers for a supporting UART to the ZPUFlex project. */

#include "uart.h"

//int thread2main(int argc,char **argv)
//{
//}

char buf1[256];
char buf2[256];

int main(int argc,char **argv)
{
	char c;
	int c2;
	int i;
	char *p1=buf1;
	char *p2=buf2;
	int *p3=(int *)buf1;
	int *p4=(int *)buf2;
	for(i=0;i<20;++i)
	{
		c=*p1++;
		*p2++=c;
	}
	for(i=0;i<20;++i)
	{
		*p4++=*p3++;
	}
	return(0);
}

