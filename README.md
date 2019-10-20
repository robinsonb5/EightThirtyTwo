# EightThirtyTwo
An experimental CPU core with 8-bit instruction words and 32-bit registers.

The main design goals are modest logic footprint and minimum possible use
of BlockRAM - which is achieved by (a) aiming to maximise code density,
and (b) having the register file implemented as logic rather than BlockRAM.

In order to maximise code density, the instruction words are only 1-byte
long, with only three bits devoted to the operand.  This allows one of
eight general purpose registers to be selected, while a ninth "tmp" register
provides an implicit second operand.

## Registers
* r0 - r6 - General Purpose Registers.  R6 is suggested as a stack pointer
but nothing in the ISA enforces this.
* r7 - Program Counter.  Only bits 0 - 27 of this are used as an address;
bits 28-31 are used interally as flags to simplify context switching.
* tmp - Implicit second operand

## Conditional execution
There are no conditional branch instructions; instead we have a "cond"
instruction which predicates the following instructions upon a condition
being met.  Valid conditions are:
* EX - execute no matter what.
* NEX - don't execute no matter what.
* EQ - execute only if the last result was equal to zero.
* NEQ - execute only if the last result was not zero.
* SLT - execute only if the last result was strictly less than zero.
* LE - execute only if the last result was less than or equal to zero.
* SGT - execute only if the last result was strictly greater than zero.
* GE - execute only if the last result was greater than or equal to zero.

## Flags
* Zero - set if the result of the last ALU operation or memory load was zero.
* Carry - set if the last ALU operation overflowed.  In order to accommodate
both signed and unsigned comparisons the meaning of the carry bit can be
modified with a "sgn" instruction.
* Cond - set if a "cond" instruction's predicates weren't met, and thus 
instructions should be skipped over.  Cleared by either a subsequent "cond"
instruction or by passing an instruction that would have changed program flow
by writing to r7.
* Sign - set by the "sgn" instruction, and cleared by the next ALU instruction.

## Program counter and flow control
There are no branch, jump or return instructions; instead r7 is designated as
the Program Counter.  Reads from r7 return the current PC 1, i.e. the next
instruction to be executed; the instruction "exg r7" will jump to a 
subroutine address in tmp, at the same time moving the return address into
tmp.  The add instruction is special-cased for r7 - it normally leaves tmp
untouched, but for r7 it places its previous value in tmp - again providing
a return address for a PC-relative branch.

## Instruction set
The ISA has 27 instructions, most of which take one nominated operand and
one implicit operand:

### Move instructions
* mr rn  -  Move the contents of the temp register to rn
* mt rn  -  Move the contents of rn to the temp register
* exg rn  -  Move the contents of rn to the temp register

### Misc instructions
* li <imm>  -  Load a 6-bit immediate value to the temp register,
sign-extended to 32 bits.  If the previous instruction was also "li" then
tmp is shifted six bits left and the new immediate value is or-ed into the
lower six bits.  32 bits immediates can thus be loaded by chaining up to six
li instructions.  "ldinc r7" may be a better solution for larger immediates,
however.
* cond <predicate>  -  test the Z and C flags against <predicate>.  If the
test fails, subsequent instructions will be skipped until the CPU encounters
either another "cond" instruction or an instruction that would
have written to r7.
* sgn  -  Sets the sgn flag, which modifies the "cmp", "shr" and "mul"
instructions.  Any subsequent ALU instruction will clear it again.

### Load instructions
All load instructions will set or clear the zero flag based on the loaded
value.
* ld rn  -  Loads from the address in rn and writes the result to tmp.
* ldt  -  Loads from the address in tmp, and writes the result to tmp.
* ldinc rn  -  Loads from the address in rn, writes the result tmp,
increments rn by 4.  
* ldbinc rn  -  Loads a single byte from the address in rn,
writes the result to tmp, increments rn by 1.
* ldidx rn  -   Loads from the sum of rn and tmp, writes the result to
tmp.

### Store instructions
* st rn  -  Stores the contents of tmp to the address in rn.
* sth  rn  -  Stores the lower 16-bits of tmp to the address in rn.
* stdec rn  -  Stores the contents of tmp to the address in rn, decrements
rn.
* stbinc rn  -  Stores the lowest byte of tmp to the address in rn,
increments rn
* stmpdec rn  -  Stores the contents of rn to the address in tmp,
decrements tmp.

### Arithmetic, Bitwise and Shift instructions
All ALU instructions set or clear the Zero flag based on the result.
Add, addt, sub, cmp and mul will also set or clear the Carry flag.

* add rn  -  Add tmp to rn, write the result to rn.  If rn is r7 then
the old value will be written to tmp, allowing it to serve as a link register.
* addt rn  -  Add tmp to rn, write result to tmp.
* sub rn  -  Subtract tmp from rn
* cmp rn  -  Subtract tmp from rn, discard result but set flags.
* mul rn  -  32x32 to 64 bit multiply.  The upper 32 bits go to tmp, the
lower 32 bits go to rn.  The multiplication will be signed if the sgn flag
is set, unsigned otherwise.
* and rn  -  Bitwise and rn with tmp, result to rn
* or rn  -  Bitwise or rn with tmp, result to rn
* xor rn  -  Bitwise xor rn with tmp, result to rn
* shl rn  -  Shift rn left by tmp bits.
* shr rn  -  Shift rn right by tmp bits.  If the sgn flag is clear then
zeroes will be shifted in - otherwise the leftmost bit of rn will be copied.
* ror rn  -  Rotate rn right by tmp bits.

Note: The shift and rotate instructions are slow - if you're shifting by a
fixed amount the mul instruction will be faster.

