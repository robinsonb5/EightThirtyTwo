/* search for possible addressing-modes */

/* To Do: Determine whether a given ob is disposable. */

struct IC *am_find_adjustment(struct IC *p,int reg)
{
	struct IC *p2=p->next;
	// FIXME - limit how many steps we check...
	/* Look for a post-increment */
	while(p2)
	{
		if(p2->code==ADDI2P)
		{
			printf("Found Addi2p to register %s \n",regnames[p2->z.reg]);
			if(((p2->q2.flags&KONST)==0)||((p2->z.flags&REG)==0))
			{
				printf("not a constant, however - bailing out. %x\n",p2->z.flags);
				p2=0;
			}
			if(p2->z.reg==reg)
			{
				printf("Adjusting the correct register\n");
				break;
			}
			else
				printf("Wrong register - keep looking\n");
		}
		else if( (p2->q1.flags&(REG|DREFOBJ) && p2->q1.reg==reg)
			|| (p2->q1.flags&(REG|DREFOBJ) && p2->q1.reg==reg)
			|| (p2->z.flags&(REG|DREFOBJ) && p2->z.reg==reg) )
		{
			printf("Found another instruction referencing reg - bailing out\n");
			p2=0;
		}
		// FIXME - check for control flow changes
		if(p2)
			p2=p2->next;
	}
	if(p2)
		return(p2);
	printf("No postincrements found - checking for predecrements\n");
	/* Search for a predecrement */
	p2=p->prev;
	while(p2)
	{
		if(p2->code==SUBIFP)
		{
			printf("Found subifp to register %s \n",regnames[p2->z.reg]);
			if(((p2->q2.flags&KONST)==0)||((p2->z.flags&REG)==0))
			{
				printf("not a constant, however - bailing out. %x\n",p2->z.flags);
				p2=0;
			}
			if(p2->z.reg==reg)
			{
				printf("Adjusting the correct register\n");
				break;
			}
			else
				printf("Wrong register - keep looking\n");
		}
		if( (p2->q1.flags&(REG|DREFOBJ) && p2->q1.reg==reg)
			|| (p2->q1.flags&(REG|DREFOBJ) && p2->q1.reg==reg)
			|| (p2->z.flags&(REG|DREFOBJ) && p2->z.reg==reg) )
		{
			printf("Found another instruction referencing reg - bailing out\n");
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
			if(target && offset!=-4)	// We only support predec for writing.
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
	printf("Validated offset is %d\n",offset);
	return(offset);
}

void am_prepost_incdec(struct IC *p,struct obj *o)
{
	struct IC *p2=0;
	if(o->flags&(REG)&&(o->flags&DREFOBJ))
	{
		printf("Referencing register %s - searching for adjustments\n",regnames[o->reg]);
		p2=am_find_adjustment(p,o->reg);

		if(p2)	// Did we find a candidate for postinc / predec?
		{
			int adj=am_get_adjvalue(p2,p->typf,o==&p->z);	// Validate the adjustment
			if(adj)
			{
				p2->code=NOP;	// Nullify the manual adjustment if we can do it as an opcode side-effect
				o->am=mymalloc(sizeof(struct AddressingMode));
				o->am->type=(adj>0) ? AM_POSTINC : AM_PREDEC;
			}
		}
	}
}

static void find_addressingmodes(struct IC *p)
{
	int c;
	struct obj *o;
	struct AddressingMode *am;

	for(;p;p=p->next){
		c=p->code;
		printf("Code %x\t",c);
		switch(c)
		{
			case KOMMA:
				printf("Komma\n");
				break;
			case ASSIGN:
				printf("Assign\n");
				am_prepost_incdec(p,&p->q1);
				am_prepost_incdec(p,&p->q2);
				am_prepost_incdec(p,&p->z);
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
	}
}

