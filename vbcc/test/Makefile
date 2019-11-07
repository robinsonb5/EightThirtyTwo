832DIR=../../Lib/

all: compiler helloworld.bin

compiler:
	make -C .. TARGET=832

clean :
	rm *.o
	rm *.bin

%.bin : %.elf Makefile
	objcopy -Obinary $< $@

%.o : %.s Makefile
	gcc -c $*.s

%.elf : start.o %.o
	gcc -Wl,--build-id=none -nostartfiles -nostdlib -Tldscript.ld -o $@ $+

%.o : %.S Makefile ldscript.ld $(832DIR)/start.S
	gcc -I$(832DIR) -c $*.S -o $*.o

%.o : $(832DIR)/%.S Makefile ldscript.ld $(832DIR)/assembler.pp $(832DIR)/start.S
	gcc -c $(832DIR)/$*.S -I$(832DIR) -o $*.o

%.s : %.832 Makefile
	cpp -P $< > $*.s

%.S : %.c Makefile ../bin/vbcc832
	../bin/vbcc832 -+ -O=15 -size -I$(832DIR) $*.c
	mv $*.asm $*.S

