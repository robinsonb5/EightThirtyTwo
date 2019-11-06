ROMGENDIR = ../romgen
ROMGEN = $(ROMGENDIR)/romgen

all:


clean :
	rm *.o
	rm *.bin

%.bin : %.o Makefile
	objcopy -Obinary $*.o $@

%.o : %.s Makefile
	gcc -c $*.s

%.o : %.S Makefile assembler.pp
	gcc -c $*.S

%.s : %.832 Makefile
	cpp -P $< > $*.s

%_ROM.vhd: %.bin $(ROMGEN)
	sed 's/dualportram/$*_ROM/' >$*_ROM.vhd <$(ROMGENDIR)/rom_prologue.vhd
	$(ROMGEN) -b $*.bin >>$*_ROM.vhd
	cat >>$*_ROM.vhd $(ROMGENDIR)/rom_epilogue.vhd

$(ROMGEN): $(ROMGENDIR)/romgen.c
	gcc -o $(ROMGENDIR)/romgen $(ROMGENDIR)/romgen.c

