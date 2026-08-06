COMMON_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

include $(COMMON_DIR)common_qpp.mk

CFLAGS += -Ilib/libqpp/public

TARGETS += lib/libqpp/libqpp.a

ALL_OBJS := \
	lib/libqpp/list.o \
	lib/libqpp/lru.o \
	lib/libqpp/hashmap.o \
	lib/libqpp/qlog.o \
	lib/libqpp/fs.o

# Static libraries
$(TARGETS): $(ALL_OBJS)
	$(AR) rcs $@ $^

all: $(TARGETS)

install: all

clean:
	rm -f $(TARGETS) $(addsuffix .sym,$(TARGETS)) $(ALL_OBJS)
	rm -rf $(DESTDIR)
