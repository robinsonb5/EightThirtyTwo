# Makefile for toolchain and tests

all: 832a/832a 832emu/832e lib832/lib832.a hello vbcc/bin/vbcc832 test

832a/832a:
	make -C 832a

832emu/832e:
	make -C 832emu

vbcc/bin/vbcc832: vbcc/supp.h vbcc/bin
	make -C vbcc TARGET=832

lib832/lib832.a: 832a/832a 832a/832l vbcc/bin/vbcc832
	make -C lib832

test:
	make -C vbcc/test emu

hello: 832emu/832e 832a/832a
	832emu/832e 832a/hello

vbcc/supp.h:
	$(error Extract the latest vbcc source archive into vbcc then try again.)

vbcc/bin/vbcc832:
	make -C vbcc TARGET=831

vbcc/bin:
	mkdir vbcc/bin

