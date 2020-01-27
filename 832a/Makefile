all: 832a 832l

832a: 832a.c 832defs.c program.c section.c symbol.c codebuffer.c 832util.c hexdump.c
	gcc -o $@ $+

832l: 832l.c 832defs.c executable.c objectfile.c section.c symbol.c codebuffer.c 832util.c hexdump.c
	gcc -o $@ $+

