all: 832a 832l 832d hello

clean:
	-rm 832a
	-rm 832l
	-rm 832d
	-rm hello

832a: 832a.c 832defs.c objectfile.c section.c symbol.c codebuffer.c 832util.c
	gcc -o $@ $+

832l: 832l.c 832defs.c executable.c objectfile.c section.c symbol.c codebuffer.c sectionmap.c 832util.c
	gcc -o $@ $+

832d: 832d.c 832defs.c 832util.c
	gcc -o $@ $+

hello: start.S premain.S hello.S uart.S
	./832a $+
	./832l -o $@ $(patsubst %.S,%.o,$+)

