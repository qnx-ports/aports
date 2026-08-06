include version.mk

CC ?= cc
AR ?= ar
STRIP ?= strip
OBJCOPY ?= objcopy

DESTDIR ?= pkg

CFLAGS = -fPIC -D_FORTIFY_SOURCE=2
CFLAGS += -g
CFLAGS += -DVERSION=\"$(QPP_VERSION)\"

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

define build_binary
$1: $2
	$$(CC) $$(CFLAGS) $$(LDFLAGS) -o $$@ $$^ $$(LDLIBS)
	cp $$@ $$@.sym
	$$(STRIP) --strip-debug $$@
	$$(OBJCOPY) --add-gnu-debuglink=$$@.sym $$@
endef
