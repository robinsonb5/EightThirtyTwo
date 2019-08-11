all:


clean :
	rm *.o
	rm *.bin

%.bin : %.o Makefile
	objcopy -Obinary $*.o $@

%.o : %.s Makefile
	gcc -c $*.s

%.o : %.S Makefile
	gcc -c $*.S

%.s : %.832 Makefile
	cpp -P $< > $*.s

