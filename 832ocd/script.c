/* Functions for executing scripts.
   Intended for uploading ROM images to a virtual SPI register over JTAG.

   The command set and syntax will be the same as the UI itself.
*/

#include <stdio.h>
#include <stdlib.h>

#include "script.h"

static char strbuf[256];

#define ISWHITESPACE(c) (c==' ' || c=='\t' || c=='\r' || c=='\n')

int script_next_non_whitespace(FILE *f)
{
	int c=' ';
	while(ISWHITESPACE(c) && c!=EOF)
		c=fgetc(f);
	if(c==EOF)
		c=0;
	return(c);
}

void script_to_eol(FILE *f)
{
	int c=0;
	while(c!='\r' && c!='\n' && c!=EOF)
		c=fgetc(f);
}

int script_get_string(FILE *f)
{
	unsigned int i=0;
	strbuf[0]=0;
	int c=script_next_non_whitespace(f);
	while((i<sizeof(strbuf)-1) && (!ISWHITESPACE(c)) && c!=EOF)
	{
		strbuf[i++]=c;
		c=fgetc(f);
	}
	strbuf[i]=0;
	return(i);
}

unsigned int script_get_int(FILE *f)
{
	unsigned int result;
	if(script_get_string(f))
	{
		char *endptr;
		result=strtoul(strbuf,&endptr,0);
		if(endptr==&strbuf[0])
		{
			printf("Bad number found: %s\n",strbuf);
			result=0;
		}
	}
	return(result);
}


int execute_script(struct ocd_frontend *ui,struct ocd_connection *con,const char *filename)
{
	int result=0;
	if(con && filename)
	{
		FILE *script=fopen(filename,"r");
		if(!script)
			return(result);
		while(!feof(script))
		{
			int c=fgetc(script);
			unsigned int addr;
			unsigned int val;
			switch(c)
			{
				case '#':
					script_to_eol(script);
					break;

				case 'r':
					addr=script_get_int(script);
					ocd_frontend_memof(ui,"R - %x: %x",addr,OCD_READ(con,addr));
					break;		

				case 'w':
					addr=script_get_int(script);
					val=script_get_int(script);
					ocd_frontend_memof(ui,"W - %x: %x",addr,val);
					OCD_WRITE(con,addr,val);
					break;		

				case 'p':
				case 'P':
					addr=script_get_int(script);
					script_get_string(script);
					ocd_frontend_memo(ui,"Sending PIO data");
					if(ocd_piofile(con,strbuf,addr))
						ocd_frontend_memo(ui,"Success");
					else
						ocd_frontend_memo(ui,"Failed");
					break;

				case '\n':
				case '\r':
					break;
					
				default:
					script_to_eol(script);
					break;
			}
		}
		OCD_READ(con,0); /* Finish with a read to wait until upload is complete */
		ocd_release(con);
		result=1;
		fclose(script);
	}
	return(result);
}

#if 0
int main(int argc,char **argv)
{
	struct ocd_connection con;
	if(argc==2)
	{
		execute_script(&con,argv[1]);
	}
	return(0);
}
#endif

