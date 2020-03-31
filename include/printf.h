#ifndef PRINTF_H
#define PRINTF_H

#include <stdarg.h>

#ifdef DISABLE_PRINTF
#define printf(x,...) // FIXME - not compatible with vbcc
#define puts(x)
#else
int printf(const char *fmt, ...);
int vprintf(const char *fmt, va_list ap);
#endif

#endif

