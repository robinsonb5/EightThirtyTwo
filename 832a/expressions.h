#ifndef EXPRESSIONS_H
#define EXPRESSIONS_H

enum operator {
	OP_PARENTHESES,
	OP_MULTIPLY,OP_DIVIDE,OP_SHLEFT,OPT_SHRIGHT,
	OP_ADD,OP_SUBTRACT,OP_AND,OP_OR,OP_XOR,
	OP_NEGATE,OP_INVERT,OP_VALUE,OP_END,OP_NONE
};

enum optype {
	OPTYPE_NULL,
	OPTYPE_PAREN,
	OPTYPE_UNARY,
	OPTYPE_BINARY
};

struct linebuffer
{
	char *buf;
	int cursor;
	enum operator currentop;
};

struct expression
{
	enum operator op;
	struct expression *left, *right; /* for branches */
	char *value; /* for leaves */
	void *storage; /* Freed on destruction */
};


struct expression *expression_new();
void expression_delete();

struct expression *expression_parse(const char *str);



#endif
