MEMORY
{
   mem : ORIGIN = 0x0, LENGTH = 0x0010000
}

SECTIONS
{
	. = 0x0;
	_start = .;
	.code : {
	  *(.startup)
	  *(.text)
	  *(.rodata)
	  *(.rodata.*)
	  *(.data)
	  *(.note.gnu.build-id)
	} >mem
	.extra : {
		__bss_start__ = . ;
	  *(.bss)
	  	__bss_end__ = . ;
	} >mem
	.eh_frame : {
	  *(.eh_frame)
	}
}

