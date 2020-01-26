#ifndef CODEBUFFER_H
#define CODEBUFFER_H

/* CODEBUFFERSIZE must be a power of 2 */
#define CODEBUFFERSIZE 4096

struct codebuffer
{
	struct codebuffer *next;
	char *buffer;
	int cursor;
};

struct codebuffer *codebuffer_new();
void codebuffer_delete(struct codebuffer *buf);

int codebuffer_write(struct codebuffer *buf,int val);

void codebuffer_dump(struct codebuffer *buf);

#endif

