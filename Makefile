# Makefile for toolchain and tests

all: 832a/832a 832emu/832e lib832/lib832.a 832ocd/832ocd hello vbcc/bin/vbcc832 test

832a/832a:
	-make -C 832a

832emu/832e:
	-make -C 832emu

832ocd/832ocd:
	-make -C 832ocd

lib832/lib832.a: 832a/832a 832a/832l vbcc/bin/vbcc832
	-make -C lib832

hello: 832emu/832e 832a/832a
	-832emu/832e 832a/hello

vbcc/supp.h:
	$(error Extract the latest vbcc source archive into vbcc then try again.)

vbcc/bin:
	mkdir vbcc/bin

vbcc/bin/vbcc832: vbcc/supp.h vbcc/bin
	-make -C vbcc TARGET=832

test:
	-make -C vbcc/test emu

