SECTIONS
{
	. = 0x0;
	_start = .;
	CODE : {
	  *startup*
	}
	.code : {
	  *(.text)
	  *(.rodata)
	  *(.rodata.*)
	  *(.data)
	}
	.extra : {
		__bss_start__ = . ;
	  *(.bss)
	  	__bss_end__ = . ;
	}
	.eh_frame : {
	  *(.eh_frame)
	}
}

ENTRY(start)
