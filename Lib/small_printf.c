#include "uart.h"
#include "stdarg.h"

#define PRINTF_HEX_ONLY
static char temp[80];

static int _cvt(int val, char *buf, int radix)
{
#ifdef PRINTF_HEX_ONLY
	int c;
	int i;
	int nz=0;
	if(val<0)
	{
		putchar('-');
		val=-val;
	}
	if(val)
	{
		for(i=0;i<8;++i)
		{
			c=(val>>28)&0xf;
			val<<=4;
			if(c)
				nz=1;	// Non-zero?  Start printing then.
			if(c>9)
				c+='A'-10;
			else
				c+='0';
			if(nz)	// If we've encountered only zeroes so far we don't print.
				putchar(c);
		}
	}
	else
		putchar('0');
	return(0);
#else
    char *cp = temp;
	const char *digits="0123456789ABCDEF";
    int length = 0;

	if(val<0)
	{
		putchar('-');
		val=-val;
	}
    if (val == 0) {
        /* Special case */
        *cp++ = '0';
    } else {
        while (val) {
			unsigned int c;
			c=val%radix;
            *cp++ = digits[c];
            val /= radix;
        }
    }
    while (cp != temp) {
        *buf++ = *--cp;
        length++;
    }
    *buf = '\0';
    return (length);
#endif
}

static char vpfbuf[sizeof(long long)*8];

int small_printf(const char *fmt, ...)
{
    va_list ap;
    int ret=0;
	int c;
	int nextfmt=0;
	int length;

    va_start(ap, fmt);

	while((c=*fmt++))
	{
		if(nextfmt)
		{
			nextfmt=0;
			length=0;
	        // Process output
	        switch (c) {
			    case 'd':
			        ret+=length = _cvt(va_arg(ap,int), vpfbuf, 10);
				    break;
			    case 'x':
			        ret+=length = _cvt(va_arg(ap,int), vpfbuf, 16);
				    break;
			    case 's':
			        ret+=puts(va_arg(ap, char *));
			        break;
				case 'l':
					nextfmt=1;
					break;
			    case 'c':
			        putchar(va_arg(ap, int /*char*/));
					ret++;
			        continue;
			    default:
			        putchar('%');
			        putchar(c);
			        continue;
	        }
		}
		else
		{
			if(c=='%')
				nextfmt=1;
			else
				putchar(c);
		}
	}
	va_end(ap);
    return (ret);
}

