#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "equates.h"


struct equate *equate_new(const char *identifier, int value)
{
	struct equate *result=0;
	if(result=(struct equate *)malloc(sizeof(struct equate)))
	{
		result->identifier=strdup(identifier);
		result->value=value;
		result->next=0;
	}
	return(result);	
}


void equate_delete(struct equate *equ)
{
	if(equ)
	{
		if(equ->identifier)
			free(equ->identifier);
		free(equ);
	}
}


int equate_getvalue(struct equate *equ,struct equate *equatelist)
{
	if(equ)
	{
		return(equ->value);
	}
	exit(1);
}
