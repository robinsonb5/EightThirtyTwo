/*
To do: 
	Peephole optimise away such constructs as mr r0, mt r0
	| Optimise addresses of stack variables - lea's can mostly be replaced with simple adds.
	Detect absolute moves to reg, prune any that aren't needed.

*/

zmax val2zmax(FILE *f,struct obj *o,int t)
{
	union atyps *p=&o->val;
	t&=NU;
	if(t==CHAR) return(zc2zm(p->vchar));
	if(t==(UNSIGNED|CHAR)) return(zuc2zum(p->vuchar));
	if(t==SHORT) return(zs2zm(p->vshort));
	if(t==(UNSIGNED|SHORT)) return(zus2zum(p->vushort));

	/*
	if(t==FLOAT) return(zf2zld(p->vfloat);emitzld(f,vldouble);}
	if(t==DOUBLE){vldouble=zd2zld(p->vdouble);emitzld(f,vldouble);}
	if(t==LDOUBLE){emitzld(f,p->vldouble);}
	*/

	if(t==INT) return(zi2zm(p->vint));
	if(t==(UNSIGNED|INT)) return(zui2zum(p->vuint));
	if(t==LONG) return(zl2zm(p->vlong));
	if(t==(UNSIGNED|LONG)) return(zul2zum(p->vulong));
	if(t==LLONG) return(zll2zm(p->vllong));
	if(t==(UNSIGNED|LLONG)) return(zull2zum(p->vullong));
	if(t==MAXINT) return(p->vmax);
	if(t==(UNSIGNED|MAXINT)) return(p->vumax);
	if(t==POINTER) return(zul2zum(p->vulong));
	printf("#FIXME - no float support yet\n");
	ierror(0);
}


static void emit_sizemod(FILE *f,int type)
{
	emit(f,"\t\t//sizemod based on type 0x%x\n",type);
	switch(type&NQ)
	{
		case CHAR:
			emit(f,"\tbyt\n");
			break;
		case SHORT:
			emit(f,"\thlf\n");
			break;
		case INT:
		case LONG:
		case POINTER:
		case FUNKT: // Function pointers are dereferenced by calling them.
		case STRUCT:
		case UNION:
		case ARRAY:
			break; // Structs and unions have to remain as pointers
		default:
			printf("emit_sizemod - type %d not handled\n",type);
			ierror(0);
			break;
	}
}


static void emit_pcreltotemp(FILE *f,char *lab,int suffix)
{
	printf("Warning: PC Relative offsets are currently (arbitrarily) restricted to 12 bits.\n");
	emit(f,"\t\t\t//pcreltotemp - FIXME - might need more bits; we currently only support 12-bit signed offset.\n");
	emit(f,"\tli\tIMW1(PCREL(%s%d)-1)\n",lab,suffix);
	emit(f,"\tli\tIMW0(PCREL(%s%d))\n",lab,suffix);
}


static void emit_externtotemp(FILE *f,char *lab,int offset)	// FIXME - need to find a way to do this PC-relative.
{
	emit(f,"\tldinc\t%s\n",regnames[pc]);
	if(offset)
		emit(f,"\t.int\t_%s + %d\n",lab,offset);
	else
		emit(f,"\t.int\t_%s\n",lab);
}



static void emit_statictotemp(FILE *f,char *lab,int suffix,int offset) // FIXME - need to find a way to do this PC relative
{
	emit(f,"\t\t\t\t//statictotemp\n");
	emit(f,"\tldinc\t%s\n",regnames[pc]);
	emit(f,"\t.int\t%s%d+%d\n",lab,suffix,offset);
}


static int count_constantchunks(zmax v)
{
	int chunk=1;
	int v2=(int)v;
	while(((v2&0xffffffe0)!=0) && ((v2&0xffffffe0)!=0xffffffe0)) // Are we looking at a sign-extended 6-bit value yet?
	{
//		 printf("%08x\n",v2);
		 v2>>=6;
		 ++chunk;
	}
	return(chunk);
}


static void emit_constanttotemp(FILE *f,zmax v)
{
	int chunk=count_constantchunks(v);

	emit(f,"\t\t\t\t// constant: %x in %d chunks\n",v,chunk);

	 while(chunk--) // Do we need to emit the top two bits?
	 {
		 emit(f,"\tli\tIMW%d(%d)\n",chunk,v);
	 }
}


static void emit_stackvartotemp(FILE *f,zmax offset,int deref)
{
	if(deref)
	{
		if(offset)
		{
			emit_constanttotemp(f,offset);
			emit(f,"\tldidx\t%s\n",regnames[sp]);
		}
		else
			emit(f,"\tld\t%s\n",regnames[sp]);
	}
	else
	{
		if(offset)
		{
			emit_constanttotemp(f,offset);
			emit(f,"\taddt\t%s\n",regnames[sp]);
		}
		else
			emit(f,"\tmt\t%s\n",regnames[sp]);	
	}
}

static void emit_prepobj(FILE *f,struct obj *p,int t,int reg,int offset)
{
	emit(f,"\t\t\t\t\t// (prepobj %s)",regnames[reg]);

	if(p->flags&DREFOBJ)
	{
		if(p->flags&VARADR)
			emit(f,"varadr AND ");
		emit(f," deref\n");
		/* Dereferencing a pointer */
		if(p->flags&KONST){
			emit(f,"\t\t\t// const\n");
			emit_constanttotemp(f,val2zmax(f,p,p->dtyp)+offset);
			if(reg!=tmp)
				emit(f,"\tmr\t%s\n",regnames[reg]);
		} else if(p->flags&REG){
			if(reg==tmp)
				emit(f,"\tmt\t%s\n",regnames[p->reg]);
			else
				emit(f,"\t\t\t\t// reg %s - no need to prep\n",regnames[p->reg]);
		} else if(p->flags&VAR) {
			emit(f,"\t\t\t\t// var FIXME - deref?");
			if(isauto(p->v->storage_class)){
				emit(f," reg \n");
				emit_stackvartotemp(f,real_offset(p)+offset,1);
				if(reg!=tmp)
					emit(f,"\tmr\t%s\n",regnames[reg]);
			} else if(isstatic(p->v->storage_class)){
				emit(f," static\n");
				emit(f,"\tldinc\tr7\n\t.int\t%s%d+%d\n",labprefix,zm2l(p->v->offset),offset+p->val.vmax);
				emit(f,"\tldt\n");
				if(reg!=tmp)
					emit(f,"\tmr\t%s\n",regnames[reg]);
			} else if(isextern(p->v->storage_class)){
				emit(f,"\n");
				emit_externtotemp(f,p->v->identifier,p->val.vmax);
				emit(f,"\tldt\n");
				if(reg!=tmp)
					emit(f,"\tmr\t%s\n",regnames[reg]);
			}
			else {
				printf("emit_prepobj (deref): - unknown storage class!\n");
				ierror(0);
			}
//				if(!zmeqto(l2zm(0L),p->val.vmax)){
//					emit(f," offset ");
//					emit(f," FIXME - deref?\n");
//					emit_constanttotemp(f,val2zmax(f,p,LONG));
//					emit(f,"\tmr\t%s\n",regnames[reg]);
//					emit_pcreltotemp(f,labprefix,zm2l(p->v->offset));
//					emit(f,"\tadd\t%s\n",regnames[reg]);
//				}
		}
	}
	else
	{
		if(p->flags&REG){
			emit(f," reg %s - no need to prep\n",regnames[p->reg]);
		}else if(p->flags&VAR) {
			if(isauto(p->v->storage_class))
			{
				/* Set a register to point to a stack-base variable. */
				emit(f," var, auto|reg\n");
				if(p->v->storage_class==REGISTER) emit(f,"\t\t\t// (is actually REGISTER)\n");
				emit_stackvartotemp(f,real_offset(p)+offset,0);
				if(reg!=tmp)
					emit(f,"\tmr\t%s\n\n",regnames[reg]);
			} else if(isextern(p->v->storage_class)){
				emit(f," extern (offset %d)\n",p->val.vmax);
				emit_externtotemp(f,p->v->identifier,p->val.vmax+offset);
				emit(f,"// extern pe %s varadr\n", p->flags&VARADR ? "is" : "not");
				if(reg!=tmp)
					emit(f,"\tmr\t%s\n",regnames[reg]);
			} else if(isstatic(p->v->storage_class)){
				emit(f," static\n");
				emit(f,"\tldinc\tr7\n\t.int\t%s%d+%d\n",labprefix,zm2l(p->v->offset),offset+p->val.vmax);
				emit(f,"// static pe %s varadr\n", p->flags&VARADR ? "is" : "not");
				if(reg!=tmp)
					emit(f,"\tmr\t%s\n",regnames[reg]);
			}else{
				printf("emit_prepobj: - unknown storage class!\n");
				ierror(0);
			}
		}
	}
}


static void emit_objtotemp(FILE *f,struct obj *p,int t)
{
	emit(f,"\t\t\t\t\t// (objtotemp) ");
	if((p->flags&(KONST|DREFOBJ))==(KONST|DREFOBJ)){
		emit(f," const/deref\n");
		emit_prepobj(f,p,t,tmp,0);
		emit_sizemod(f,t);
		emit(f,"\tldt\n");
		return;
	}

	if(p->flags&DREFOBJ)
	{
		emit(f," deref \n");
		/* Dereferencing a pointer */
		if(p->flags&REG){
			switch(t&NQ)
			{
				case CHAR:
					if(p->am && p->am->type==AM_POSTINC)
						emit(f,"\tldbinc\t%s\n",regnames[p->reg]);
					else if(p->am && p->am->disposable)
						emit(f,"\tldbinc\t%s\n//Disposable, postinc doesn't matter.\n",regnames[p->reg]);
					else
						emit(f,"\tbyt\n\tld\t%s\n",regnames[p->reg]);
					break;
				case SHORT:
					emit(f,"\thlf\n");
					emit(f,"\tld\t%s\n",regnames[p->reg]);
					break;
				case INT:
				case LONG:
				case POINTER:
					if(p->v)
						emit(f,"\t//(offset %d)\n",p->v->offset);
					if(p->v)
						emit(f,"\t//(val %d)\n",p->val.vlong);
					if(p->am && p->am->type==AM_POSTINC)
						emit(f,"\tldinc\t%s\n",regnames[p->reg]);
					else
						emit(f,"\tld\t%s\n",regnames[p->reg]);
					break;
				case FUNKT: // Function pointers are dereferenced by calling them.
					emit(f,"\tmt\t%s\n",regnames[p->reg]);
				default:
					emit(f,"//FIXME - unhandled type %d\n",t);
					break;
			}
		}
		else {
			emit_prepobj(f,p,t,tmp,0);
			// FIXME - array type?
			if((t&NQ)!=FUNKT && (t&NQ)!=STRUCT && (t&NQ)!=UNION) // Function pointers are dereferenced by calling them.
			{
				emit_sizemod(f,t);
				emit(f,"\tldt\n//marker 2\n");
			}
		}
	}
	else
	{
		if(p->flags&REG){
			emit(f," reg %s, offset %d, val %d\n",regnames[p->reg],p->v->offset,p->val.vmax);
			emit(f,"\tmt\t%s\n",regnames[p->reg]);
		}else if(p->flags&VAR) {
			if(isauto(p->v->storage_class)) {
				emit(f," var, auto|reg\n");
				emit_sizemod(f,t);
				if(real_offset(p)) {
					emit_constanttotemp(f,real_offset(p));
					emit(f,"\tldidx\t%s\n",regnames[sp]);
				}
				else
					emit(f,"\tld\t%s\n",regnames[sp]);
			}
			else if(isextern(p->v->storage_class)) {
				emit(f," extern\n");
				emit_externtotemp(f,p->v->identifier,p->val.vmax);
				emit_sizemod(f,t);
				// Structs and unions have to remain as pointers
				if((!(p->flags&VARADR)) && ((t&NQ)!=STRUCT) && ((t&NQ)!=UNION) && ((t&NQ)!=ARRAY))
				{
					emit(f,"\t//extern deref\n");
					emit(f,"\tldt\n");
				}
			}
			else if(isstatic(p->v->storage_class))
			{
				emit(f,"//static %s\n", p->flags&VARADR ? "varadr" : "not varadr");
				emit_statictotemp(f,labprefix,zm2l(p->v->offset),p->val.vmax);
				// Structs and unions have to remain as pointers
				if((!(p->flags&VARADR)) && ((t&NQ)!=STRUCT) && ((t&NQ)!=UNION) && ((t&NQ)!=ARRAY))
				{
					emit(f,"\t//static deref\n");
					emit(f,"\tldt\n");
				}
			}
			else
			{
				printf("Objtotemp: Unhandled storage class: %d\n",p->v->storage_class);
				ierror(0);
			}
		}
		else if(p->flags&KONST){
			emit(f," const\n");
			emit_constanttotemp(f,val2zmax(f,p,t));
		}
		else {
			printf("Objtotemp: unknown flags %d\n",p->flags);
			ierror(0);
		}
	}
}


