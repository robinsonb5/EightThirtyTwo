#include <stdio.h>
#include <string.h>

struct mystruct
{
	char *str;
};

struct mystruct st;

char strbuf[20];

int main(int argc,char **argv)
{
	st.str="Hello, world!\n";

	strcpy(strbuf,"Hello, world!\n");

	puts(strbuf);
	puts(st.str);

	return(0);
}
