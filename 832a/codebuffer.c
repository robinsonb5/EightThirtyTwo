#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "hexdump.h"
#include "codebuffer.h"

struct codebuffer *codebuffer_new()
{
	struct codebuffer *buf=(struct codebuffer *)malloc(sizeof(struct codebuffer));
	if(buf)
	{
		buf->next=0;
		buf->buffer=malloc(CODEBUFFERSIZE);
		buf->cursor=0;
	}
	return(buf);	
}

void codebuffer_delete(struct codebuffer *buf)
{
	if(buf)
	{
		if(buf->buffer)
			free(buf->buffer);
		free(buf);
	}
}

int codebuffer_write(struct codebuffer *buf,int val)
{
	if(!buf)
		return(0);
	if(buf->cursor<CODEBUFFERSIZE);
	{
		buf->buffer[buf->cursor]=val;
		++buf->cursor;
		return(1);
	}
	return(0);
}


int codebuffer_loadchunk(struct codebuffer *buf,int bytes,FILE *f)
{
	buf->cursor=fread(buf->buffer,bytes,1,f);
}


void codebuffer_output(struct codebuffer *buf,FILE *f)
{
	fwrite(buf->buffer,buf->cursor,1,f);
}


void codebuffer_dump(struct codebuffer *buf)
{
	if(buf)
	{
		hexdump(buf->buffer,buf->cursor);
	}
}
