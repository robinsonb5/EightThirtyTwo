#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "expressions.h"

struct operatordef {
	char *key;
	enum operator op;
	enum optype type;
} operators[]=
{
	{"(",OP_PARENTHESES,OPTYPE_PAREN},
	{"*",OP_MULTIPLY,OPTYPE_BINARY},
	{"/",OP_DIVIDE,OPTYPE_BINARY},
	{"<<",OP_SHLEFT,OPTYPE_BINARY},
	{">>",OPT_SHRIGHT,OPTYPE_BINARY},
	{"+",OP_ADD,OPTYPE_BINARY},
	{"-",OP_SUBTRACT,OPTYPE_BINARY},
	{"&",OP_AND,OPTYPE_BINARY},
	{"|",OP_OR,OPTYPE_BINARY},
	{"^",OP_XOR,OPTYPE_BINARY},
	{"-",OP_NEGATE,OPTYPE_UNARY},
	{"~",OP_INVERT,OPTYPE_UNARY},
	{"!",OP_INVERT,OPTYPE_UNARY},
	{0,OP_VALUE,OPTYPE_NULL},
	{0,OP_END,OPTYPE_NULL},
	{0,OP_NONE,OPTYPE_NULL}
};



/*

Expression parsing
Need to support the following binary operators:
+, -, *, /, &, |, ^, <<, >>
Also unary operators: -, ~

Build a tree structure for expression parsing.

Scan the expression from left to right searching for operators.
Create a leaf from everything up to the first operator.
If none is found we have a value, set op and value fields accordingly.
If an operator is found, create a 2nd value leaf from anything up to the next operator.
If another operator was found, compare priorities:
  If priority is higher than the first operator, recursively create a new expression with current expression as its left branch.
If priorty is higher than the first operator, set this as a leaf and return to caller.
If no further operators are found, set this as a leaf and return to caller.
If brackets are found, anything within the brackets should be evaluated as a separate expression.
*/

struct linebuffer *linebuffer_new(char *buf)
{
	struct linebuffer *result;
	if(result=(struct linebuffer *)malloc(sizeof(struct linebuffer)))
	{
		result->cursor=0;
		result->buf=buf;
		result->currentop=OP_NONE;
	}
}

void linebuffer_delete(struct linebuffer *lb)
{
	if(lb)
		free(lb);
}


/* Function to extract a subexpression into a new linebuffer. 
   Modifies the supplied linebuffer in-place, replacing ‘)’ with a \nul,
   And advances the cursor accordingly.
   Returns either a new linebuffer or null on failure. */

struct linebuffer *linebuffer_extractsubexpr(struct linebuffer *lb)
{
	struct linebuffer *result=0;
	int parencount=0;
	int i=0;
	int c;
	if(!lb)
		return(0);

	i=lb->cursor;
	if(lb->buf[i]!='(')    /* Not a subexpression? */
		return(0);

	while(c=lb->buf[i])
	{
		if(c=='(')
			++parencount;
		else if (c==')')
		{
			--parencount;
			if(parencount==0)
			{
				printf("Terminating first expression\n");
				lb->buf[i]=0; /* Terminate the subexpression */        
				printf("Creating new lb\n");
				result=linebuffer_new(&lb->buf[lb->cursor+1]);
				lb->cursor=i+1;
				return(result);
			}
		}
		printf("i: %d, parencount: %d\n",i,parencount);
		++i;
	}
	return(result);
}


struct operatordef *matchoperator(char *str)
{
	int i;
	for(i=0;i<(sizeof(operators)/sizeof(struct operatordef));++i)
	{
		if(operators[i].key)
		{
			if(strncmp(operators[i].key,str,strlen(operators[i].key))==0)
				return(&operators[i]);
		}
		else
			return(0);
	}
}

/* advance the cursor past the next operator, return the operator, and null it out. */
enum operator expression_findoperator(struct linebuffer *lb)
{
	if(lb && lb->buf)
	{
		struct operatordef *result;
		while(lb->buf[lb->cursor])
		{
			while(lb->buf[lb->cursor]==' ' || lb->buf[lb->cursor]=='\t')
				++lb->cursor;

			if(result=matchoperator(&lb->buf[lb->cursor]))
			{
				int i;
				/*	If we found the operator, set currentop in the linebuffer structure
					and zero out its text representation in the string. */
				printf("Found operation %d\n",result->op);
				lb->currentop=result->op;
				for(i=0;i<strlen(result->key);++i)
					lb->buf[lb->cursor++]=0;
				return(result->op);
			}
			++lb->cursor;
		}
		lb->currentop=OP_END;
		return(0);
	}
}


struct expression *expression_new()
{
	struct expression *result;
	if(result=(struct expression *)malloc(sizeof(struct expression)))
	{
		result->left=result->right=0;
		result->value=0;
		result->op=OP_NONE;
		result->storage=0;
	}
	return(result);
}


void expression_delete(struct expression *expr)
{
	if(expr)
	{
		if(expr->storage)
			free(expr->storage);
		if(expr->left)
			expression_delete(expr->left);
		if(expr->right)
			expression_delete(expr->right);
		free(expr);
	}
}


/*	Create a leaf node from everything up to the next operator, setting the value field
	Fill in the operator field with OP_value.
	Fill in buf with operator, if any.
	Zero-out the operator character(s).
	Advance cursor
*/

struct expression *expression_buildtree(struct linebuffer *lb);

struct expression *expression_makeleaf(struct linebuffer *lb)
{
	struct expression *result;
	/* If the expression begins with brackets, extract the subexpression and build a tree from it. */
	if(lb->buf[lb->cursor]=='(')
	{
		struct linebuffer *subexpr=linebuffer_extractsubexpr(lb);
		result=expression_buildtree(subexpr);
		linebuffer_delete(subexpr);
		expression_findoperator(lb);
	}
	else if(result=expression_new())
	{
		result->value=&lb->buf[lb->cursor];
		result->op=OP_VALUE;
		expression_findoperator(lb);
		printf("created leaf: %s\n",result->value);
	}
	return(result);
}


struct expression *expression_makerightleaf(struct expression *leftleaf,struct linebuffer *lb)
{
	struct expression *expr,*expr2;
	expr=expression_new();
	expr->left=leftleaf;
	expr->op=lb->currentop;
	printf("assigning %s to right hand\n",&lb->buf[lb->cursor]);
	expr2=expression_makeleaf(lb);
	/* 	If another operator was found, compare priorities:
		If priority is higher than the first operator, recursively create a new expression
		with current expression as its left branch. */

	while(lb->currentop<expr->op)
	{
		printf("Creating new righthand leaf\n");
		expr2=expression_makerightleaf(expr2,lb);
	}
	expr->right=expr2;
	return(expr);
}


struct expression *expression_buildtree(struct linebuffer *lb)
{
	struct expression *expr=0;
	struct expression *expr2=0;
	enum operator op;

	printf("Buildtree: %s\n",&lb->buf[lb->cursor]);

	/* 	Scan the expression from left to right searching for operators.
		Create a leaf from everything up to the first operator. */
		
	expr=expression_makeleaf(lb);

	while(lb->currentop!=OP_END)
	{
		/* If an operator is found, create a 2nd value leaf from anything up to the next operator. */
		expr=expression_makerightleaf(expr,lb);
	}
	return(expr);
}


void expression_dumptree(struct expression *expr,int indent)
{
	int i;
	if(expr)
	{
		if(expr->value)
		{
			for(i=0;i<indent;++i) printf("  ");
			printf("Value: %s\n",expr->value);
		}
		if(expr->left)
		{
			for(i=0;i<indent;++i) printf("  ");
			printf("left: -> \n");
			expression_dumptree(expr->left,indent+1);
			for(i=0;i<indent;++i) printf("  ");
			printf("%s\n",operators[expr->op].key ? operators[expr->op].key : "(none)");
		}
		if(expr->right)
		{
			for(i=0;i<indent;++i) printf("  ");
			printf("right: -> \n");
			expression_dumptree(expr->right,indent+1);
		}
	}
}


struct expression *expression_parse(const char *str)
{
	struct expression *expr=0;
	if(str)
	{
		char *buf=strdup(str);
		struct linebuffer *lb=linebuffer_new(buf);
		expr=expression_buildtree(lb);
		if(expr)
			expr->storage=buf;
		linebuffer_delete(lb);
	}
	return(expr);
}


int main(int argc,char **argv)
{
	char *line="(3+_label24)+255*(4+7)&15";
	struct linebuffer *lb1,*lb2;
	struct expression *expr;
	enum operator op;
	if(argc>1)
		line=argv[1];
	expr=expression_parse(line);
	expression_dumptree(expr,0);
	expression_delete(expr);
	return(0);
}

