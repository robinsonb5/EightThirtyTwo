ifeq '$(findstring ;,$(PATH))' ';'
    DETECTED_OS := Windows
else
    DETECTED_OS := $(shell uname 2>/dev/null || echo Unknown)
    DETECTED_OS := $(patsubst CYGWIN%,Cygwin,$(DETECTED_OS))
    DETECTED_OS := $(patsubst MSYS%,MSYS,$(DETECTED_OS))
    DETECTED_OS := $(patsubst MINGW%,MSYS,$(DETECTED_OS))
endif

# Values Example : 
#   Windows
#   Cygwin
#   MSYS          # MSYS or MINGW
#   Darwin        # Mac OS X
#   Linux
#   GNU           # Debian GNU Hurd
#   GNU/kFreeBSD  # Debian kFreeBSD
#   FreeBSD
#   NetBSD
#   DragonFly
#   Haiku

# Use Example
#ifeq ($(detected_OS),Windows)
#    CFLAGS += -D WIN32
#endif

