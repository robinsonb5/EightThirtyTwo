832DIR=../../
LIBDIR = $(832DIR)/Lib
ROMGENDIR = ../../romgen
ROMGEN = $(ROMGENDIR)/romgen
GHDL = ghdl
AS=../../832a/832a
LD=../../832a/832l
CC=../bin/vbcc832
COPT = -O=32767 -speed
CFLAGS = -+ $(COPT) -I$(832DIR)/include/ -I$(LIBDIR)
TIME=2ms
all: compiler dhrystone_ROM.vhd

compiler:
	make -C .. TARGET=832

run: dhrystone.ghw

clean :
	-rm *.asm
	-rm *.o
	-rm *.bin

a.out : dhry_1.c dhry_2.c ../../Lib/hexdump.c
	gcc $+

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

dhrystone.bin : $(LIBDIR)/start.o $(LIBDIR)/uart.o $(LIBDIR)/small_printf.o $(LIBDIR)/division.o $(LIBDIR)/string.o dhry_1.o dhry_2.o
	$(LD) -m $@.map -o $@ $+

%.o : %.S Makefile $(LIBDIR)/start.S $(CC)
	$(AS) $*.S

%.o : %.asm Makefile $(LIBDIR)/start.S $(CC)
	$(AS) $*.asm

%.asm : %.c Makefile ldscript.ld $(LIBDIR)/start.S $(CC)
	../bin/vbcc832 $(CFLAGS) $(COPT) $*.c

%.o : %.c Makefile ldscript.ld $(LIBDIR)/start.S $(CC)
	../bin/vbcc832 $(CFLAGS) $(COPT) $*.c
	$(AS) $*.asm

%.o : $(LIBDIR)/%.S Makefile ldscript.ld $(832DIR)/Lib/assembler.pp $(LIBDIR)/start.S $(CC)
	$(AS) $(LIBDIR)/$*.S

%.o : $(LIBDIR)/%.asm Makefile ldscript.ld $(832DIR)/Lib/assembler.pp $(LIBDIR)/start.S $(CC)
	$(AS) $(LIBDIR)/$*.asm

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

