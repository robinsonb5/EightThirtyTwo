all:
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

%.o : %.S Makefile ldscript.ld assembler.pp start.S
	gcc -c $*.S -o $*.o

%.s : %.832 Makefile
	cpp -P $< > $*.s

%.S : %.c Makefile ../bin/vbcc832
	../bin/vbcc832 -+ -O=15 -size $*.c
	mv $*.asm $*.S

