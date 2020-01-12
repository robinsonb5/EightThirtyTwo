832DIR=../../
ROMGENDIR = ../../romgen
ROMGEN = $(ROMGENDIR)/romgen
GHDL = ghdl
CC=../bin/vbcc832
COPT = -O=1311 -speed
CFLAGS = -+ $(COPT) -pcrel-reach=2
TIME=2ms
all: compiler dhrystone_ROM.vhd

compiler:
	make -C .. TARGET=832

run: dhrystone.ghw

clean :
	rm *.S
	rm *.o
	rm *.bin
	rm *.elf

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

%.bin : %.elf Makefile
	objcopy -Obinary $< $@

%.o : %.s Makefile
	gcc -c $*.s

dhrystone.elf : start.o uart.o small_printf.o tiny_printf.o division.o string.o dhry_1.o dhry_2.o hexdump.o
	gcc -Wl,--build-id=none -Wl,--gc-sections -nostartfiles -nostdlib -Tldscript.ld -o $@ $+

%.o : %.S Makefile ldscript.ld $(832DIR)/Lib/start.S
	gcc -I. -I$(832DIR)/include -I$(832DIR)/Lib -c $*.S -o $*.o

%.o : %.c Makefile ldscript.ld $(832DIR)/Lib/start.S $(CC)
	../bin/vbcc832 $(CFLAGS) -I$(832DIR)/include -I$(832DIR)/Lib $*.c
	mv $*.asm $*.S
	gcc -I. -I$(832DIR)/Lib -c $*.S -o $*.o

%.o : $(832DIR)/Lib/%.S Makefile ldscript.ld $(832DIR)/Lib/assembler.pp $(832DIR)/Lib/start.S
	gcc -c $(832DIR)/Lib/$*.S -I$(832DIR)/include -I$(832DIR)/Lib -o $*.o

%.S : %.c Makefile ../bin/vbcc832
	../bin/vbcc832 $(CFLAGS) -I$(832DIR)/include -I$(832DIR)/Lib $*.c
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

force:

