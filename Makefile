# Makefile for toolchain and tests

all: 832a 832e vbcc test

832a:
	make -C 832a

832e:
	make -C 832emu

vbcc: vbcc/supp.h vbcc/bin
	make -C vbcc TARGET=832

test:
	make -C vbcc/test emu

vbcc/supp.h:
	@echo "Extract the latest vbcc source archive into vbcc then try again."

vbcc/bin:
	mkdir vbcc/bin

