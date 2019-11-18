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
	emit(f,"#FIXME - no float support yet\n");
}


static void emit_pcreltotemp(FILE *f,char *lab,int suffix)
{
	emit(f,"#pcrel - FIXME - might need more bits; we currently only support 12-bit signed offset.\n");
	emit(f,"\tli\tIMW1(PCREL(%s%d)-1)\n",lab,suffix);
	emit(f,"\tli\tIMW0(PCREL(%s%d))\n",lab,suffix);
}


static void emit_externtotemp(FILE *f,char *lab,int offset)
{
	emit(f,"\tldinc\t%s\n",regnames[pc]); // Assuming 16 bits will be enough for offset.
	if(offset)
		emit(f,"\t.int\t_%s + %d\n",lab,offset);
	else
		emit(f,"\t.int\t_%s\n",lab);
}



static void emit_statictotemp(FILE *f,char *lab,int suffix)
{
	emit(f,"#static\n");
	emit(f,"\tldinc\t%s\n",regnames[pc]); // Assuming 16 bits will be enough for offset.
	emit(f,"\t.int\t%s%d\n",lab,suffix);
}


static void emit_constanttotemp(FILE *f,zmax v)
{
	int chunk=1;
	// FIXME - simple single-byte cases:
	int v2=(int)v;
	while(((v2&0xffffffe0)!=0) && ((v2&0xffffffe0)!=0xffffffe0)) // Are we looking at a sign-extended 8-bit value yet?
	{
		 printf("%08x\n",v2);
		 v2>>=6;
		 ++chunk;
	}

	emit(f,"\t\t\t\t// constant: %x in %d chunks\n",v,chunk);

	 while(chunk--) // Do we need to emit the top two bits?
	 {
		 emit(f,"\tli\tIMW%d(%d)\n",chunk,v);
	 }
}


static void emit_prepobj(FILE *f,struct obj *p,int t,int reg,int offset)
{
	emit(f,"\t\t\t\t\t// (prepobj %s)",regnames[reg]);
	if(p->am){
		emit(f,"# FIXME - extended addressing modes not supported\n");
		return;
	}
	if((p->flags&(KONST|DREFOBJ))==(KONST|DREFOBJ)){
		emit(f," const/deref\n");
		emit_constanttotemp(f,val2zmax(f,p,p->dtyp));
		if(reg!=tmp)
			emit(f,"\tmr\t%s\n",regnames[reg]);
		return;
	}

	if(p->flags&DREFOBJ)
	{
		emit(f," deref ");
		/* Dereferencing a pointer */
		if(p->flags&REG){
		if(reg==tmp)
			emit(f,"\tmt\t%s\n",regnames[p->reg]);
		else
			emit(f," reg %s - no need to prep\n",regnames[p->reg]);
		}
		else if(p->flags&VAR) {	// FIXME - figure out what dereferencing means in these contexts
			emit(f," var FIXME - deref?");
			if(p->v->storage_class==AUTO||p->v->storage_class==REGISTER){
				emit(f," reg \n");
				if(real_offset(p)+offset!=0)
				{
					emit_constanttotemp(f,real_offset(p)+offset);

					// FIXME - if we're dereferencing for a read here, can use ldidx.
					emit(f,"\taddt\t%s\n",regnames[sp]);
				}
				else
					emit(f,"\tmt\t%s\n",regnames[sp]);
				emit(f,"\tldt\n");
				if(reg!=tmp)
					emit(f,"\tmr\t%s\n",regnames[reg]);
			}

			else{
				if(!zmeqto(l2zm(0L),p->val.vmax)){
					emit(f," offset ");
					emit(f," FIXME - deref?");
					emit_constanttotemp(f,val2zmax(f,p,LONG));
					emit(f,"\tmr\t%s\n",regnames[reg]);
					emit_pcreltotemp(f,labprefix,zm2l(p->v->offset));
					emit(f,"\tadd\t%s\n",regnames[reg]);
				}
				if(p->v->storage_class==STATIC){
					emit(f," static\n");
					emit(f," FIXME - deref?");
					emit(f,"\tldinc\tr7\n\t.int\t%s%d\n",labprefix,zm2l(p->v->offset));
					if(reg!=tmp)
						emit(f,"\tmr\t%s\n",regnames[reg]);
				}else{
					emit(f," FIXME - deref?");
					emit_externtotemp(f,p->v->identifier,p->val.vmax);
					if(reg!=tmp)
						emit(f,"\tmr\t%s\n",regnames[reg]);
				}
			}
		}
	}
	else
	{

		if(p->flags&REG){
			emit(f," reg %s - no need to prep\n",regnames[p->reg]);

		}else if(p->flags&VAR) {
			if(p->v->storage_class==AUTO||p->v->storage_class==REGISTER)
			{
				/* Set a register to point to a stack-base variable. */
				emit(f," var, auto|reg\n");
				if(p->v->storage_class==REGISTER) emit(f,"# (is actually REGISTER)\n");
				if(real_offset(p)+offset==0)	/* No offset? Just copy the stack pointer */
				{
					emit(f,"\tmt\t%s\n",regnames[sp]);
					if(reg!=tmp)
						emit(f,"\tmr\t%s\n",regnames[reg]);
				}
				else
				{
					emit_constanttotemp(f,real_offset(p)+offset);
					emit(f,"\taddt\t%s\n",regnames[sp]);
					if(reg!=tmp)
						emit(f,"\tmr\t%s\n\n",regnames[reg]);
				}
			}
			else{
				if(isextern(p->v->storage_class)){
					emit(f," extern (offset %d)\n",p->val.vmax);
					emit_externtotemp(f,p->v->identifier,p->val.vmax);
					if(reg!=tmp)
						emit(f,"\tmr\t%s\n",regnames[reg]);
				}
				else if(isstatic(p->v->storage_class)){
					emit(f," static\n");
					emit(f,"\tldinc\tr7\n\t.int\t%s%d\n",labprefix,zm2l(p->v->offset));
					if(reg!=tmp)
						emit(f,"\tmr\t%s\n",regnames[reg]);
				}else{
					emit(f," FIXME - unknown storage class!\n");
				}
#if 0
				if(!zmeqto(l2zm(0L),p->val.vmax)){
					emit(f," offset (p->val.vmax==0) - storage class: %x ",p->v->storage_class);
					emit_constanttotemp(f,val2zmax(f,p,LONG));
					emit(f,"\tmr\t%s\n",regnames[reg]);
					emit_pcreltotemp(f,labprefix,zm2l(p->v->offset));
					emit(f,"\tadd\t%s\n",regnames[reg]);
				}
#endif
			}
		}
	}
//	if(p->flags&KONST){
//		emit_constanttotemp(f,val2zmax(f,p,t));
//	}
}


static void emit_objtotemp(FILE *f,struct obj *p,int t)
{
	emit(f,"\t\t\t\t\t// (objtotemp)");
	if(p->am){
		emit(f,"# FIXME - extended addressing modes not supported\n");
		return;
	}
	if((p->flags&(KONST|DREFOBJ))==(KONST|DREFOBJ)){
		emit(f," const/deref # FIXME deal with different data sizes when dereferencing\n");
		emit_prepobj(f,p,t,t1,0);
		emit(f,"\tld\t%s\n",regnames[t1]);
		return;
	}

	if(p->flags&DREFOBJ)
	{
		emit(f," deref \n");
		/* Dereferencing a pointer */
		if(p->flags&REG){
			emit(f,"\tld\t%s\n",regnames[p->reg]);
		}
		else {
			emit_prepobj(f,p,t,tmp,0);
			emit(f,"\tldt\n");
		}
	}
	else
	{
		if(p->flags&REG){
			emit(f," reg %s\n",regnames[p->reg]);
			emit(f,"\tmt\t%s\n",regnames[p->reg]);
		}else if(p->flags&VAR) {
			if(p->v->storage_class==AUTO||p->v->storage_class==REGISTER)
			{
				emit(f," var, auto|reg\n");
				if(real_offset(p))
				{
					emit_constanttotemp(f,real_offset(p));
					emit(f,"\tldidx\t%s\n",regnames[sp]);
				}
				else
					emit(f,"\tld\t%s\n",regnames[sp]);
			}
			else{
				if(!zmeqto(l2zm(0L),p->val.vmax)){
					emit(f," offset ");
					emit_constanttotemp(f,val2zmax(f,p,LONG));
					emit(f,"\tmr\t%s\n",regnames[t1]);
		// FIXME - not pc-relative!
					emit_pcreltotemp(f,labprefix,zm2l(p->v->offset));
					emit(f,"\taddt\t%s\n",regnames[t1]);
		// FIXME - probably need to load here.
				}
				if(p->v->storage_class==STATIC){
					emit(f,"# static\n");
					emit_statictotemp(f,labprefix,zm2l(p->v->offset));
				}else{
					// FIXME - have to deal with offsets here.
					emit(f,"// storage class %d\n",p->v->storage_class);
					emit_externtotemp(f,p->v->identifier,p->val.vmax);
				}
			}
		}
		else if(p->flags&KONST){
			emit(f," const\n");
			emit_constanttotemp(f,val2zmax(f,p,t));
		}
		else {
			emit(f," unknown type %d\n",p->flags);
		}
	}
}


