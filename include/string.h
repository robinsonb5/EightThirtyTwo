#ifndef _STRING_H
#define _STRING_H

#include <stddef.h>

 void *memccpy(void *, const void *, int, size_t);
 void *memchr(const void *, int, size_t);
 void *memrchr(const void *, int, size_t);
 int memcmp(__reg("r3") const void *, __reg("r2") const void *, __reg("r1") size_t);
 int memcpy(__reg("r3") const void *, __reg("r2") const void *, __reg("r1") size_t);
 int memmove(__reg("r3") const void *, __reg("r2") const void *, __reg("r1") size_t);
 void *memset(__reg("r3") void *, __reg("r2") int,__reg("r1") size_t);
 void *memmem(const void *, size_t, const void *, size_t);
 void memswap(void *, void *, size_t);
 void bzero(void *, size_t);
 int strcasecmp(const char *, const char *);
 int strncasecmp(const char *, const char *, size_t);
 char *strcat(__reg("r2") char *, __reg("r1") const char *);
 char *strchr(const char *, int);
 char *index(const char *, int);
 char *strrchr(const char *, int);
 char *rindex(const char *, int);
 int strcmp(__reg("r2") const char *, __reg("r1") const char *);
 char *strcpy(__reg("r2") char *, __reg("r1") const char *);
 char *strncpy(__reg("r3") char *, __reg("r2") const char *, __reg("r1") size_t);
 size_t strcspn(const char *, const char *);
 char *strdup(const char *);
 char *strndup(const char *, size_t);
 char *strerror(int);
 char *strsignal(int);
 size_t strlen(__reg("r1") const char *);
 size_t strnlen(const char *, size_t);
 char *strncat(__reg("r2") char *, __reg("r1") const char *, __reg("r3") size_t);
 size_t strlcat(char *, const char *, size_t);
 int strncmp(__reg("r2") const char *, __reg("r1") const char *, __reg("r3") size_t);
 size_t strlcpy(char *, const char *, size_t);
 char *strpbrk(const char *, const char *);
 char *strsep(char **, const char *);
 size_t strspn(const char *, const char *);
 char *strstr(const char *, const char *);
 char *strtok(char *, const char *);
 char *strtok_r(char *, const char *, char **);

#endif				/* _STRING_H */
