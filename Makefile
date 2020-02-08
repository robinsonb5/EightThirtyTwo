# Makefile for toolchain and tests

all: 832a/832a 832emu/832e vbcc/bin/vbcc832 test

832a/832a:
	make -C 832a

832emu/832e:
	make -C 832emu

vbcc/bin/vbcc832: vbcc/supp.h vbcc/bin
	make -C vbcc TARGET=832

test:
	make -C vbcc/test emu

vbcc/supp.h:
	$(error Extract the latest vbcc source archive into vbcc then try again.)

vbcc/bin:
	mkdir vbcc/bin

