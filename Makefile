# Makefile for toolchain and tests

include check_os.mk

all: test.log
	$(info )
	$(info A default dtgen setup is supplied in vbcc_quickstart to make building )
	$(info the compiler less tedious.  If you want to build on a less typical system )
	$(info delete vbcc/machines/832/dt.* then run the following command to recompile:)
	$(info > make -C vbcc TARGET=832)
	$(info )
	$(info NB: Take note of the terms of the VBCC license if you intend to distribute)
	$(info a product which incorporates code compiled for 832.)
	$(info )

clean:
	-make -C 832a DETECTED_OS=$(DETECTED_OS) clean
	-make -C 832emu DETECTED_OS=$(DETECTED_OS) clean
	-make -C 832ocd DETECTED_OS=$(DETECTED_OS) clean
	-make -C lib832 DETECTED_OS=$(DETECTED_OS) clean
	-make -C romgen DETECTED_OS=$(DETECTED_OS) clean
	-rm vbcc/machines/832/*.o
	-rm vbcc/bin/vbcc832
	-rm test.log

.PHONY: toolchain
toolchain:
	-make -C 832a DETECTED_OS=$(DETECTED_OS)
	-make -C 832emu DETECTED_OS=$(DETECTED_OS)
	-make -C 832ocd DETECTED_OS=$(DETECTED_OS)
	-make -C romgen DETECTED_OS=$(DETECTED_OS)

.PHONY: library
library:
	-make -C lib832 DETECTED_OS=$(DETECTED_OS) clean 
	-make -C lib832 DETECTED_OS=$(DETECTED_OS)

vbcc0_9g.tar.gz:
	wget http://phoenix.owl.de/tags/vbcc0_9g.tar.gz

vbcc/supp.h:
	tar -xzf vbcc0_9g.tar.gz
	cd vbcc; \
	mkdir bin; \
	patch -i ../vbcc_09g_volatilefix.patch

vbcc/bin/vbcc832: vbcc/machines/832/machine.c vbcc/supp.h
	make -C vbcc DETECTED_OS=$(DETECTED_OS) bin/dtgen
	cp vbcc_quickstart/dt.* vbcc/machines/832/
	make -C vbcc TARGET=832 DETECTED_OS=$(DETECTED_OS)

vbcc/bin:
	mkdir vbcc/bin

.PHONY vbcc:
vbcc: vbcc/bin/vbcc832

test.log: toolchain vbcc/bin/vbcc832 library
	-@make -C vbcc/test DETECTED_OS=$(DETECTED_OS) emu 2>/dev/null >test.log
	-@grep --color=never Passed test.log
	-@grep Failed test.log || echo "All tests passed"

force:

