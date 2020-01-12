void emit_inlinememcpy(FILE *f,struct IC *p, int t)
{
	int srcr = t1;
	int dstr=0;
	int saved=1;
	int cntr=0;
	int savec=1;
	int wordcopy;
	int bytecopy;
	zmax copysize = opsize(p);
	int unrollwords=0;
	int unrollbytes=0;

	// Can we create larger code in the interests of speed?  If so, partially unroll the copy.
	// FIXME - this is broken
	wordcopy = copysize & ~3;
	bytecopy = copysize - wordcopy;

	if (wordcopy < 32 && !optsize)
		unrollwords=1;
	if (bytecopy < 5)
		unrollbytes=1;

	cleartempobj(f,t1);
	cleartempobj(f,tmp);

	printf("Getting regs\n");

	if(dstr=availreg())
	{
		regs[dstr]=1;
		saved=0;
	}
	else
	{
		dstr=t1+1;
		emit(f,"\tmt\t%s\n",regnames[dstr]);
		emit(f,"\tstdec\t%s\n",regnames[sp]);
		pushed+=4;
	}
	emit(f,"//using reg %s for dst pointer\n",regnames[dstr]);

	// FIXME - don't necessarily need the counter register if the copy is small...

	if(unrollwords && unrollbytes)
		savec=0;
	else if(cntr=availreg())
	{
		regs[cntr]=1;
		savec=0;
	}
	else
	{
		cntr=t1+2;
		emit(f,"\tmt\t%s\n",regnames[cntr]);
		emit(f,"\tstdec\t%s\n",regnames[sp]);
		pushed+=4;
	}
	emit(f,"//using reg %s for counter\n",regnames[cntr]);

	emit_prepobj(f, &p->z, t, dstr, 0);
	if ((t & NQ) == CHAR && (opsize(p) != 1)) {
//		printf("t&nq: %d, opsize(p) %d, vmax %d\n", t & NQ, opsize(p),
//		      zm2l(p->q2.val.vmax));
		emit(f, "// (char with size!=1 -> array of unknown type)\n");
		t = ARRAY;	// FIXME - ugly hack
	}
	// If the target pointer happens to be in r2, we have to swap dstr and cntr!
	if (p->z.flags & REG) {
		if (p->z.reg == cntr)	// Collision - swap registers
		{
			int tr;
			emit(f, "\t\t\t//Swapping dest and counter registers\n");
			tr=cntr;
			cntr = dstr;
			dstr = tr;
		} else if(p->z.reg!=dstr) // Move target register to dstr
		{
			emit(f, "\tmt\t%s\n", regnames[p->z.reg]);
			emit(f, "\tmr\t%s\n", regnames[dstr]);
		}
	}

	// FIXME - could unroll more agressively if optspeed is set.  Can then avoid messing with r2.
	emit(f, "// Copying %d words and %d bytes to %s\n", wordcopy / 4, bytecopy,
	     p->z.v ? p->z.v->identifier : "(null)");

	if(!p->z.v)
		printf("No z->v: z flags: %x\n",p->z.flags);

	// Prepare the copy
	// FIXME - we don't necessarily have a valid z->v!  If not, where does the target come from?
	// Stack based variable?
	emit_objtotemp(f, &p->q1, t);
	emit(f, "\tmr\t%s\n", regnames[srcr]);


	if (unrollwords) {
		wordcopy >>= 2;
		if (wordcopy)
		{
			emit(f, "// Copying %d words to %s\n", wordcopy, p->z.v ? p->z.v->identifier : "(null)");
		}
		while (wordcopy--) {
			emit(f, "\tldinc\t%s\n\tstinc\t%s\n", regnames[srcr], regnames[dstr]);
		}
	} else {
		emit(f, "// Copying %d words to %s\n", wordcopy / 4, p->z.v ? p->z.v->identifier : "(null)");
		// Copy bytes...
		emit_constanttotemp(f, wordcopy);
		emit(f, "\taddt\t%s\n", regnames[dstr]);
		emit(f, "\tmr\t%s\n", regnames[cntr]);
		emit(f, ".cpy%swordloop%d:\n", p->z.v ? p->z.v->identifier : "null", loopid);
		emit(f, "\tldinc\t%s\n\tstinc\t%s\n", regnames[srcr], regnames[dstr]);
		emit(f, "\tmt\t%s\n\tcmp\t%s\n", regnames[dstr], regnames[cntr]);
		emit(f, "\tcond\tNEQ\n");
		emit(f, "\t\tli\tIMW0(PCREL(.cpy%swordloop%d))\n", p->z.v ? p->z.v->identifier : "null", loopid);
		emit(f, "\t\tadd\t%s\n", regnames[pc]);
	}

	if (unrollbytes) {
		if (bytecopy)
			emit(f, "// Copying %d byte tail to %s\n", bytecopy,p->z.v ? p->z.v->identifier : "null");
		while (bytecopy--)
			emit(f, "\tldbinc\t%s\n\tstbinc\t%s\n", regnames[srcr], regnames[dstr]);
	} else {
		emit(f, "// Copying %d bytes to %s\n", bytecopy, p->z.v ? p->z.v->identifier : "null");
		// Copy bytes...
		emit_constanttotemp(f, bytecopy);
		emit(f, "\taddt\t%s\n", regnames[dstr]);
		emit(f, "\tmr\t%s\n", regnames[cntr]);
		emit(f, ".cpy%sloop%d:\n", p->z.v ? p->z.v->identifier : "null", loopid);
		emit(f, "\tldbinc\t%s\n\tstbinc\t%s\n", regnames[srcr], regnames[dstr]);
		emit(f, "\tmt\t%s\n\tcmp\t%s\n", regnames[dstr], regnames[cntr]);
		emit(f, "\tcond\tNEQ\n");
		emit(f, "\t\tli\tIMW0(PCREL(.cpy%sloop%d))\n", p->z.v ? p->z.v->identifier : "null", loopid);
		emit(f, "\t\tadd\t%s\n", regnames[pc]);

	}
	// cleanup
	if(savec)
	{
		emit(f,"\tldinc\t%s\n",regnames[sp]);
		emit(f,"\tmr\t%s\n",regnames[cntr]);
		pushed-=4;
	}
	else if(cntr)
		regs[cntr]=0;
	if(saved)
	{
		emit(f,"\tldinc\t%s\n",regnames[sp]);
		emit(f,"\tmr\t%s\n",regnames[dstr]);
		pushed-=4;
	}
	else if(dstr)
		regs[dstr]=0;
	loopid++;
}

