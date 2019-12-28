#include "uart.h"
#include "stdarg.h"

static char temp[16];

static int _cvt(int val, char *buf, unsigned int radix)
{
    char *cp = temp;
	const char *digits="0123456789ABCDEF";
    int length = 0;

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
}

static char vpfbuf[sizeof(long)*8];

__weak int printf(const char *fmt, ...)
{
    va_list ap;
    int ret=0;
	unsigned int c;
	int length;
	int nextfmt=0;

    va_start(ap, fmt);

	while((c=*fmt++))
	{
		if(nextfmt)
		{
			int val;
			int base=0;
			length=0;
			nextfmt=0;
	        // Process output
	        switch (c) {
			    case 'd':
				case 'u':
					base=10;
				    break;
			    case 'p':
			    case 'x':
					base=16;
				    break;
			    case 's':
			        ret+=puts(va_arg(ap, char *));
			        break;
				case 'l':
				case '0':
					nextfmt=1;
					break;
			    case 'c':
			        putchar(va_arg(ap, int /*char*/));
					ret++;
			        break;
			    default:
			        putchar('%');
			        putchar(c);
					ret++;
			        break;
	        }
			if(base)
			{
				val=va_arg(ap,int);
				if(c=='d' && val<0)
				{
					putchar('-');
					val=-val;
				}
		        ret+=length = _cvt(val, vpfbuf, base);
				puts(vpfbuf);
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

