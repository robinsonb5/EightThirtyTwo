/*
	Peephole optimisations for 832 assembler

	Detect and remove unnecessary opcode combinations
	such as "mr r3, mt r3".
	Potentially st r6, ld r6 too, but must be possible to disable this
	in case it causes issues with volatile registers

*/
#include <stdio.h>
#include "peephole.h"
#include "832util.h"

int peephole_test(struct peepholecontext *pc,int opcode)
{
	int result=1;
	int operand=opcode&7;
	opcode&=~7;
	if(pc)
	{
		debug(1,"Peephole comparing %x, %x with %x, %x\n",opcode,operand,pc->opcode,pc->operand);
		if(pc->operand==operand)
		{
			debug(1,"Operands match\n");
			// MT followed by MR to the same register
			if(pc->opcode==opc_mt && opcode==opc_mr)
				result=0;
			// MR followed by MT to the same register
			if(pc->opcode==opc_mr && opcode==opc_mt)
				result=0;
		}
		pc->opcode=opcode;
		pc->operand=operand;
	}
	return(result);
}


void peephole_clear(struct peepholecontext *pc)
{
	if(pc)
	{
		pc->opcode=0;
		pc->operand=0;
	}
}

