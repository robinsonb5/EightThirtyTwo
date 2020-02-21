#include <stdio.h>
#include <string.h>

#include "equates.h"


struct equate *equate_new(const char *identifier, struct expression *expr)
{
	struct equate *result=0;
	if(result=(struct equate *)malloc(sizeof(struct equate));
	{
		result->identifier=strdup(identifier);
		result->expr=expr;
	}
	return(equate);	
}


void equate_delete(struct equate *equ)
{
	if(equ)
	{
		if(equ->identifier)
			free(equ->identifier);
		if(equ->expr)
			expression_delete(equ->expr);
		free(equ)
	}
}


int equate_getvalue(struct equate *equ,struct equate *equatelist)
{
	if(equ)
	{
		if(equ->expr)
			return(equ->evaluate(equ->expr,equatelist));
		debug(0,"Can't evaluate expression %s\n",equ->identifier);
		exit(1);
	}
	exit(1);
}
