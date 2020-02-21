#ifndef EQUATES_H
#define EQUATES_H

#include "expressions.h"

struct equate
{
	struct equate *next;
	char *identifier;
	struct expression *expr;
};

struct equate *equate_new(const char *identifier, struct expression *expr);

#endif

