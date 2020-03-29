832DIR=../../
LIBDIR = $(832DIR)/lib832
ROMGENDIR = ../../romgen
ROMGEN = $(ROMGENDIR)/romgen
GHDL = ghdl
AS=../../832a/832a
LD=../../832a/832l
CC=../bin/vbcc832
COPT = -O=32767 -speed -unsigned-char
CFLAGS = -+ $(COPT) -I$(832DIR)/include/ -I$(LIBDIR)
TIME=4ms
all: compiler dhrystone_ROM.vhd

compiler:
	make -C .. TARGET=832

run: dhrystone.ghw

clean :
	-rm *.asm
	-rm *.o
	-rm *.bin

%.ghw : %_ROM.vhd  tb.vhd force
	sed 's/_rom/$*_rom/;s/cpu_tb/$*_tb/' >$*_tb.vhd <tb.vhd
	$(GHDL) -a $*_ROM.vhd
	$(GHDL) -a $*_tb.vhd
	$(GHDL) -c -r $*_tb --ieee-asserts=disable-at-0 --stop-time=$(TIME) --read-wave-opt=waveopt --wave=$*.ghw


%_ROM.vhd: %.bin $(ROMGEN)
	sed 's/dualportram/$*_rom/' >$*_ROM.vhd <$(ROMGENDIR)/rom_prologue.vhd
	$(ROMGEN) -b $*.bin >>$*_ROM.vhd
	cat >>$*_ROM.vhd $(ROMGENDIR)/rom_epilogue.vhd

%.bin : Makefile $(CC)
	objcopy -Obinary $< $@

%.o : %.asm Makefile
	$(AS) $*.asm

dhrystone.bin : $(LIBDIR)/dualcrt0.a $(LIBDIR)/lib832.a dhry_1.o dhry_2.o dhry_3.o dhry_4.o
	$(LD) -o $@ $+

%.o : %.S Makefile
	$(AS) $*.S

%.o : %.asm Makefile
	$(AS) $*.asm

%.asm : %.c Makefile
	../bin/vbcc832 $(CFLAGS) $*.c

%.o : %.c Makefile $(LIBDIR)/start.S $(CC)
	../bin/vbcc832 $(CFLAGS) $*.c
	$(AS) $*.asm

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

force:

