# Makefile for toolchain and tests

all: 832a/832a 832emu/832e 832ocd/832ocd vbcc/bin/vbcc832 lib832/lib832.a test
	$(info )
	$(info NB: Take note of the terms of the VBCC license if you intend to distribute)
	$(info a product which incorporates code compiled for 832.)

832a/832a: force
	-make -C 832a

832emu/832e: force
	-make -C 832emu

832ocd/832ocd: force
	-make -C 832ocd

lib832/lib832.a: 832a/832a 832a/832l vbcc/bin/vbcc832
	-make -C lib832 clean
	-make -C lib832

vbcc0_9g.tar.gz:
	wget http://phoenix.owl.de/tags/vbcc0_9g.tar.gz

vbcc/supp.h:
	$(info )
	$(info When configuring VBCC, if you're building on a)
	$(info typical Linux system you can just accept the defaults.)
	$(info )
	$(info NB: Take note of the terms of the VBCC license if you intend to distribute)
	$(info a product which incorporates code compiled for 832.)
	$(info )
	@read -p"Press enter" var
	tar -xzf vbcc0_9g.tar.gz
	cd vbcc; \
	mkdir bin; \
	patch -i ../vbcc_09g_volatilefix.patch

vbcc/bin/vbcc832: vbcc/machines/832/machine.c vbcc/supp.h
	make -C vbcc TARGET=832

vbcc/bin:
	mkdir vbcc/bin

.PHONY vbcc:
vbcc: vbcc/bin/vbcc832

.PHONY test:
test:
	-make -C vbcc/test emu

force:

