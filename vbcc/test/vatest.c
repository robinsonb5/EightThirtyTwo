#include "uart.h"
#include "stdarg.h"
#include "small_printf.h"

int main(int argc,char **argv)
{
	small_printf("T: %s, %c, %d\n","Testing",65,42);
	return(0);
}

#include "small_printf.c"
#include "uart.c"

