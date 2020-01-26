#include <stdio.h>

void hexdump(char *p,int l)
{
	int i=0;
	while(l--)
	{
		unsigned int t=*p++;
		unsigned int t2=(t>>4)&15;
		t2+='0'; if(t2>'9') t2+='@'-'9';
		putchar(t2);
		t2=t&15;
		t2+='0'; if(t2>'9') t2+='@'-'9';
		putchar(t2);
		++i;
		if((i&3)==0)
			putchar(' ');
		if((i&15)==0)
			putchar('\n');
	}
	putchar('\n');
}

