# Makefile for toolchain and tests

all: 832a/832a 832emu/832e lib832/lib832.a 832ocd/832ocd hello vbcc/bin/vbcc832 test

832a/832a: force
	-make -C 832a

832emu/832e: force
	-make -C 832emu

832ocd/832ocd: force
	-make -C 832ocd

lib832/lib832.a: 832a/832a 832a/832l vbcc/bin/vbcc832 force
	-make -C lib832

hello: 832emu/832e 832a/832a
	-832emu/832e 832a/hello

vbcc/supp.h:
	$(info Extract the latest vbcc source archive into vbcc then try again.)
	$(info If using vbcc 0.9g, you should also apply the vbcc_09g_volatilefix patch)
	$(info which fixes a compiler bug relating to the volatile keyword.)
	$(error vbcc is missing.)

vbcc/bin:
	mkdir vbcc/bin

vbcc/bin/vbcc832: vbcc/supp.h vbcc/bin force
	-make -C vbcc TARGET=832

test:
	-make -C vbcc/test emu

force:

