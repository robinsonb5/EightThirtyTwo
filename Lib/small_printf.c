#include "uart.h"
#include <stdarg.h>
#include <stddef.h>

static char temp[16];

typedef int (*pf_outfunc)(int c,void *ofdata);

static int _cvt(int val, unsigned int radix,pf_outfunc f,void *ofdata)
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
		f(*--cp,ofdata);
		length++;
	}
	return (length);
}

static int _pfputs(const char *s,pf_outfunc f, void *ofdata)
{
	int result=-1;
	int c;
	int cont=1;
	while(c=*s++)
	{
		++result;
		if(f(c,ofdata)!=c)
			return(result);
	}
	return(result);
}

__weak int _printfcore(const char *fmt,va_list ap,pf_outfunc f,void *ofdata)
{
    int ret=0;
	unsigned int c;
	int length;
	int nextfmt=0;

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
			        ret+=_pfputs(va_arg(ap, char *),f,ofdata);
			        break;
				case 'l':
				case '0':
					nextfmt=1;
					break;
			    case 'c':
			        f(va_arg(ap, int /*char*/),ofdata);
					ret++;
			        break;
			    default:
					if(c!='%')
						f('%',ofdata);
			        f(c,ofdata);
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
		        ret+=length = _cvt(val, base,f,ofdata);
			}
		}
		else
		{
			if(c=='%')
				nextfmt=1;
			else
				f(c,ofdata);
		}
	}
    return (ret);
}


int vprintf(const char *fmt, va_list ap)
{
	return(_printfcore(fmt,ap,(pf_outfunc)&putchar,0));	// Extraneous parameter should be OK on 832.
}

int printf(const char *fmt, ...)
{
	int ret;
    va_list ap;
	va_start(ap,fmt);
	ret=_printfcore(fmt,ap,(pf_outfunc)&putchar,0);
	va_end(ap);
	return(ret);
}

struct _fpwcdata
{
	char *buf;
	size_t len;
};

static int _fpwritechar(int c,void *ud)
{
	struct _fpwcdata *d=(struct _fpwcdata*)ud;
	if(d->len)
	{
		--d->len;
		*d->buf++=c;	// FIXME - check size modifier
		return(c);
	}
	else
		return(0);
}

int sprintf(char *buf,const char *fmt, ...)
{
	int ret;
    va_list ap;
	struct _fpwcdata ud;
	ud.buf=buf;
	ud.len=-1;
	va_start(ap,fmt);
	ret=_printfcore(fmt,ap,_fpwritechar,&ud);
	va_end(ap);
	return(ret);
}

int snprintf(char *buf,size_t size,const char *fmt, ...)
{
	int ret;
    va_list ap;
	struct _fpwcdata ud;
	ud.buf=buf;
	ud.len=size;
	va_start(ap,fmt);
	ret=_printfcore(fmt,ap,_fpwritechar,&ud);
	va_end(ap);
	return(ret);
}

int vsprintf(char *buf,const char *fmt, va_list ap)
{
	struct _fpwcdata ud;
	ud.buf=buf;
	ud.len=-1;
	return(_printfcore(fmt,ap,_fpwritechar,&ud));
}

