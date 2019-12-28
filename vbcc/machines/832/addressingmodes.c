/* search for possible addressing-modes */

/* DONE: Determine whether a given ob is disposable. */

/* ToDo: Look for pairs of ICs with Z set to register,
   followed by disposable q1 on the same register ->
   use tmp for that register.  Can we avoid the 
   passing register being allocated? */

#define AM_DEBUG 0

// If the obj doesn't already have an addressing mode, create one and zero it out.
void am_alloc(struct obj *o)
{
	if(!o->am)
	{
		o->am=mymalloc(sizeof(struct AddressingMode));
		memset(o->am,0,sizeof(struct AddressingMode));
	}
}

void am_disposable(struct IC *p,struct obj *o)
{
	struct IC *p2;
	int disposable=0;
	if(o->flags&REG)
	{
		p2=p->next;
		while(p2)
		{
			if(p2->code==FREEREG && p2->q1.reg==o->reg)
			{
				if(AM_DEBUG)
					printf("\t(%s disposable.)\n",regnames[o->reg]);
				am_alloc(o);
				o->am->disposable=1;
				return;
			}
			if( (p2->q1.flags&(REG|DREFOBJ) && p2->q1.reg==o->reg)
				|| (p2->q2.flags&(REG|DREFOBJ) && p2->q2.reg==o->reg)
				|| (p2->z.flags&(REG|DREFOBJ) && p2->z.reg==o->reg) )
			{
				//Found another instruction referencing reg - not disposable.
				return;
			}
			switch(p2->code)
			{
				case CALL:
				case BEQ:
				case BNE:
				case BLT:
				case BGE:
				case BLE:
				case BGT:
				case BRA:
					// Control flow changed, erring on the side of safety - not disposable.
					return;
					break;
				default:
					break;
			}
			p2=p2->next;
		}		
	}
}


struct IC *am_find_adjustment(struct IC *p,int reg)
{
	struct IC *p2=p->next;
	// FIXME - limit how many steps we check...
	/* Look for a post-increment */
	while(p2)
	{
		if(p2->code==ADDI2P)
		{
			if(AM_DEBUG)
				printf("\tFound Addi2p to register %s \n",regnames[p2->z.reg]);
			if((p2->q2.flags&KONST)&&(p2->z.flags&REG))
			{
				if(p2->z.reg==reg)
				{
					if(AM_DEBUG)
						printf("\t\tAdjusting the correct register - match found\n");
					break;
				}
				else
					if(AM_DEBUG)
						printf("\t\tWrong register - keep looking\n");
			}
			else
			{
				if(AM_DEBUG)
					printf("\t\tnot a constant, however - bailing out.\n");
				p2=0;
			}
		}
		else if( ((p2->q1.flags&(REG|DREFOBJ)) && p2->q1.reg==reg)
			|| ((p2->q2.flags&(REG|DREFOBJ)) && p2->q2.reg==reg)
			|| ((p2->z.flags&(REG|DREFOBJ)) && p2->z.reg==reg) )
		{
			if(AM_DEBUG)
				printf("\t\tFound another instruction referencing reg - bailing out\n");
			p2=0;
		}
		// FIXME - check for control flow changes
		if(p2)
			p2=p2->next;
	}
	if(p2)
		return(p2);
	if(AM_DEBUG)
		printf("\tNo postincrements found - checking for predecrements\n");
	/* Search for a predecrement */
	p2=p->prev;
	while(p2)
	{
		if(p2->code==SUBIFP)
		{
			if(AM_DEBUG)
				printf("\t\tFound subifp to register %s \n",regnames[p2->z.reg]);
			if((p2->q2.flags&KONST)&&(p2->z.flags&REG))
			{
				if(p2 && p2->z.reg==reg)
				{
					if(AM_DEBUG)
						printf("\t\tAdjusting the correct register - match found\n");
					break;
				}
				else
					if(AM_DEBUG)
						printf("\t\tWrong register - keep looking\n");
			}
			else
			{
				if(AM_DEBUG)
					printf("\t\tnot a constant, however - bailing out.\n");
				p2=0;
			}
		}
		else if( ((p2->q1.flags&(REG|DREFOBJ)) && p2->q1.reg==reg)
			|| ((p2->q2.flags&(REG|DREFOBJ)) && p2->q2.reg==reg)
			|| ((p2->z.flags&(REG|DREFOBJ)) && p2->z.reg==reg) )
		{
			if(AM_DEBUG)
				printf("\t\tFound another instruction referencing reg - bailing out\n");
			p2=0;
		}
		// FIXME - check for control flow changes
		if(p2)
			p2=p2->prev;
	}
	return(p2);
}

// If we have a candidate for pre/post increment/decrement, validate that we can use it,
// and return the offset.  Zero if we can't use it.
int am_get_adjvalue(struct IC *p, int type,int target)
{
	int offset=p->q2.val.vmax;
	if(p->code==SUBIFP)
		offset=-offset;
	if(AM_DEBUG)
		printf("Offset is %d, type is %d, writing to target? %s\n",offset,type&NQ,target ? "yes" : "no");
	// Validate offset against type and CPU's capabilities.
	switch(type&NQ)
	{
		case CHAR:	// We only support postincrement for CHARs
			if(offset!=1)
				offset=0;
			if(p->code==SUBIFP)
				offset=0;
			break;
		case INT:
		case LONG:
		case POINTER:	// We support post-increment and predecrement for INTs/LONGs/PTRs
//			if(target && offset!=-4)	// We only support predec for writing.
			if(target && ((offset!=-4)||(offset!=4)))	// We now support predec and postinc for writing.
				offset=0;
			if(!target && offset!=4)	// We only support postinc for reading
				offset=0;
			if(p->code==ADDI2P && offset!=4)
				offset=0;
			if(p->code==SUBIFP && offset!=-4)
				offset=0;
			break;
		case SHORT:	// We don't support either mode for shorts or anything else.
		default:
			offset=0;
	}
	if(AM_DEBUG)
		printf("Validated offset is %d\n",offset);
	return(offset);
}

void am_prepost_incdec(struct IC *p,struct obj *o)
{
	struct IC *p2=0;
	int type;
	if(o->flags&(REG)&&(o->flags&DREFOBJ))
	{
		if(AM_DEBUG)
			printf("Dereferencing register %s - searching for adjustments\n",regnames[o->reg]);
		p2=am_find_adjustment(p,o->reg);

		if(p2)	// Did we find a candidate for postinc / predec?
		{
			switch(p->code)
			{
				case CONVERT:
					if(AM_DEBUG)
						printf("\tConvert operation - type is %d\n",p->typf2);
					type=p->typf2;
					break;
				default:
					if(AM_DEBUG)
						printf("\tRegular operation - type is %d\n",p->typf);
					type=p->typf;
					break;
			}
			int adj=am_get_adjvalue(p2,type,o==&p->z);	// Validate the adjustment
			if(adj)
			{
				p2->code=NOP;	// Nullify the manual adjustment if we can do it as an opcode side-effect
				am_alloc(o);
				o->am->type=(adj>0) ? AM_POSTINC : AM_PREDEC;
			}
		}
	}
}

#define getreg(x) (x.flags&REG ? x.reg : 0)

static void find_addressingmodes(struct IC *p)
{
	int c;
	struct obj *o;
	struct AddressingMode *am;

	for(;p;p=p->next){
		c=p->code;
#if 0
		printf("Code %x\t",c);
		switch(c)
		{
			case KOMMA:
				printf("Komma\n");
				break;
			case ASSIGN:
//				printic(stdout,p);
				printf("Assign\n");
				break;
			case ASSIGNOP:
				printf("AssignOP\n");
				break;
			case COND:
				printf("Cond\n");
				break;
			case LOR:
				printf("Lor\n");
				break;
			case LAND:
				printf("Land\n");
				break;
			case OR:
				printf("Or\n");
				break;
			case XOR:
				printf("Xor\n");
				break;
			case AND:
				printf("And\n");
				break;
			case EQUAL:
				printf("Equal\n");
				break;
			case INEQUAL:
				printf("Inequal\n");
				break;
			case LESS:
				printf("Less\n");
				break;
			case LESSEQ:
				printf("LessEq\n");
				break;
			case GREATER:
				printf("Greater\n");
				break;
			case GREATEREQ:
				printf("GreaterEq\n");
				break;
			case LSHIFT:
				printf("LShift\n");
				break;
			case RSHIFT:
				printf("RShift\n");
				break;
			case ADD:
				printf("Add\n");
				break;
			case SUB:
				printf("Add\n");
				break;
			case MULT:
				printf("Mult\n");
				break;
			case DIV:
				printf("Div\n");
				break;
			case MOD:
				printf("Mod\n");
				break;
			case NEGATION:
				printf("Neg\n");
				break;
			case KOMPLEMENT:
				printf("Complement\n");
				break;
			case PREINC:
				printf("PreInc\n");
				break;
			case POSTINC:
				printf("PostInc\n");
				break;
			case PREDEC:
				printf("PreDec\n");
				break;
			case POSTDEC:
				printf("PostDec\n");
				break;
			case MINUS:
				printf("Minus\n");
				break;
			case CONTENT:
				printf("Content\n");
				break;
			case ADDRESS:
				printf("Address\n");
				break;
			case CAST:
				printf("Cast\n");
				break;
			case CALL:
				printf("Call\n");
				break;
			case INDEX:
				printf("Index\n");
				break;
			case DPSTRUCT:
				printf("DPStruct\n");
				break;
			case DSTRUCT:
				printf("DStruct\n");
				break;
			case IDENTIFIER:
				printf("Identifier\n");
				break;
			case CEXPR:
				printf("CExpr\n");
				break;
			case STRING:
				printf("String\n");
				break;
			case MEMBER:
				printf("Member\n");
				break;
			case CONVERT:
				printf("Convert\n");
				break;
			case ADDRESSA:
				printf("AddressA\n");
				break;
			case FIRSTELEMENT:
				printf("FirstElement\n");
				break;
			case PMULT:
				printf("PMult\n");
				break;
			case ALLOCREG:
				printf("AllocReg %s\n",regnames[p->q1.reg]);
				break;
			case FREEREG:
				printf("FreeReg %s\n",regnames[p->q1.reg]);
				break;
			case PCEXPR:
				printf("PCExpr\n");
				break;
			case TEST:
				printf("Test\n");
				break;
			case LABEL:
				printf("Label\n");
				break;
			case BEQ:
				printf("Beq\n");
				break;
			case BNE:
				printf("Bne\n");
				break;
			case BLT:
				printf("Blt\n");
				break;
			case BGE:
				printf("Bge\n");
				break;
			case BLE:
				printf("Ble\n");
				break;
			case BGT:
				printf("Bgt\n");
				break;
			case BRA:
				printf("Bra\n");
				break;
			case COMPARE:
				printf("Compare\n");
				break;
			case PUSH:
				printf("Push\n");
				break;
			case POP:
				printf("Pop\n");
				break;
			case ADDRESSS:
				printf("Address\n");
				break;
			case ADDI2P:
				printf("Addi2p\n");
				break;
			case SUBIFP:
				printf("Subifp\n");
				break;
			case SUBPFP:
				printf("subpfp\n");
				break;
			case PUSHREG:
				printf("Pushreg\n");
				break;
			case POPREG:
				printf("Popreg\n");
				break;
			case POPARGS:
				printf("Popargs\n");
				break;
			case SAVEREGS:
				printf("Saveregs\n");
				break;
			case RESTOREREGS:
				printf("Restoreregs\n");
				break;
			case ILABEL:
				printf("Ilabel\n");
				break;
			case DC:
				printf("DC\n");
				break;
			case ALIGN:
				printf("Align\n");
				break;
			case COLON:
				printf("Colon\n");
				break;
			case GETRETURN:
				printf("GetReturn\n");
				break;
			case SETRETURN:
				printf("SetReturn\n");
				break;
			case MOVEFROMREG:
				printf("Movefromreg\n");
				break;
			case MOVETOREG:
				printf("Movetoreg\n");
				break;
			case NOP:
				printf("Nop\n");
				break;
			case BITFIELD:
				printf("Bitfield\n");
				break;
			case LITERAL:
				printf("Literal\n");
				break;
			case REINTERPRET:
				printf("Reinterpret\n");
				break;
			default:
				break;
		}
#endif
		// Have to make sure that operands are different registers!
		if((getreg(p->q1)==getreg(p->q2))
			|| (getreg(p->q1)==getreg(p->z)))
		{
			if(getreg(p->q1))
				if(AM_DEBUG)
					printf("Collision between q1 and q2 or z - ignoring\n");
		}
		else
			am_prepost_incdec(p,&p->q1);

		if((getreg(p->q1)==getreg(p->q2))
			|| (getreg(p->q2)==getreg(p->z)))
		{
			if(getreg(p->q1))
				if(AM_DEBUG)
					printf("Collision between q2 and q1 or z - ignoring\n");
		}
		else
			am_prepost_incdec(p,&p->q2);

		if((getreg(p->q1)==getreg(p->z))
			|| (getreg(p->q2)==getreg(p->z)))
		{
			if(getreg(p->z))
				if(AM_DEBUG)
					printf("Collision between z and q1 or q2 - ignoring\n");
		}
		else
		am_prepost_incdec(p,&p->z);
		am_disposable(p,&p->q1);
		am_disposable(p,&p->q2);
		am_disposable(p,&p->z);
	}
}

