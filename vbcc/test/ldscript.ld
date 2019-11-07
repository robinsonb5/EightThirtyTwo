MEMORY
{
   mem : ORIGIN = 0x0, LENGTH = 0x0010000
}

SECTIONS
{
	. = 0x0;
	_start = .;
	.code : {
	  *(.text.startup)
	  *(.text)
	  *(.rodata)
	  *(.rodata.*)
	  *(.data)
	} >mem
	.extra : {
		__bss_start__ = . ;
	  *(.bss)
	  	__bss_end__ = . ;
	} >mem
	/DISCARD/ : {
	  *(.eh_frame)
	  *(.gnu.build-id)
	} 
}

