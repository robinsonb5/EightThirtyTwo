832DIR=../../
LIBDIR = $(832DIR)/Lib
ROMGENDIR = ../../romgen
ROMGEN = $(ROMGENDIR)/romgen
GHDL = ghdl
CC=../bin/vbcc832
CFLAGS = -+ -size -I$(832DIR)/include/ -I$(LIBDIR)
COPT = -O=1311
TIME=200000ns
all: compiler helloworld.bin

compiler:
	make -C .. TARGET=832

run: helloworld.ghw

tests: helloworld.ghw helloworld_byte.ghw strcpytest.ghw fptrtest.ghw copytest.ghw comparisons.ghw vatest.ghw

clean :
	rm *.bin
	rm *.S
	rm *.o
	rm *.elf

.PRECIOUS : %.ghw

%.gtkw : %.ghw
	sed 's/cpu_tb/$*_tb/g' >$*.gtkw <tb.gtkw

%.ghw : %_ROM.vhd  tb.vhd force
	sed 's/_rom/$*_rom/;s/cpu_tb/$*_tb/' >$*_tb.vhd <tb.vhd
	$(GHDL) -a $*_ROM.vhd
	$(GHDL) -a $*_tb.vhd
	$(GHDL) -c -r $*_tb --ieee-asserts=disable-at-0 --stop-time=$(TIME) --read-wave-opt=waveopt --wave=$*.ghw


%_ROM.vhd: %.bin $(ROMGEN) force
	sed 's/dualportram/$*_rom/' >$*_ROM.vhd <$(ROMGENDIR)/rom_prologue.vhd
	$(ROMGEN) -b $*.bin >>$*_ROM.vhd
	cat >>$*_ROM.vhd $(ROMGENDIR)/rom_epilogue.vhd

%.bin : %.elf Makefile force
	objcopy -Obinary $< $@

%.o : %.s Makefile
	gcc -c $*.s

%.elf : start.o uart.o small_printf.o tiny_printf.o division.o strcmp.o hexdump.o %.o
	gcc -Wl,--build-id=none -Wl,--gc-sections -nostartfiles -nostdlib -Tldscript.ld -o $@ $+

%.o : %.S Makefile ldscript.ld $(LIBDIR)/start.S force
	gcc -I. -I$(LIBDIR) -c $*.S -o $*.o

%.o : %.c Makefile ldscript.ld $(LIBDIR)/start.S $(CC) force
	../bin/vbcc832 $(CFLAGS) $(COPT) $*.c
	mv $*.asm $*.S
	gcc -I. -I$(LIBDIR) -I$(832DIR)/include -c $*.S -o $*.o

%.o : $(LIBDIR)/%.S Makefile ldscript.ld $(832DIR)/Lib/assembler.pp $(LIBDIR)/start.S force
	gcc -c $(LIBDIR)/$*.S -I$(832DIR)/Lib -o $*.o

%.S : %.c Makefile ../bin/vbcc832 $(CC) force
	../bin/vbcc832 $(CFLAGS) $(COPT) -I$(832DIR) $*.c
	mv $*.asm $*.S

$(ROMGEN): $(ROMGENDIR)/romgen.c
	gcc -o $(ROMGENDIR)/romgen $(ROMGENDIR)/romgen.c

init:
	$(GHDL) -a $(GHDLFLAGS) ../../RTL/eightthirtytwo_pkg.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../RTL/eightthirtytwo_aligner.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../RTL/eightthirtytwo_aligner_le.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../RTL/eightthirtytwo_fetchloadstore.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../RTL/eightthirtytwo_decode.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../RTL/eightthirtytwo_shifter.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../RTL/eightthirtytwo_alu.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../RTL/eightthirtytwo_hazard.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../RTL/eightthirtytwo_cpu.vhd
	$(GHDL) -a $(GHDLFLAGS) ../../romgen/rom_pkg.vhd
	$(GHDL) -a $(GHDLFLAGS) helloworld_ROM.vhd

force:

