COMMON_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

include $(COMMON_DIR)common_qpp.mk

CFLAGS += -Ilib/libplayback/public

TARGETS = lib/libplayback/libplayback.a

ALL_OBJS := lib/libplayback/signal_event.o

# Static libraries
$(TARGETS): $(ALL_OBJS)
	$(AR) rcs $@ $^

all: $(TARGETS)

install: all

clean:
	rm -f $(TARGETS) $(addsuffix .sym,$(TARGETS)) $(ALL_OBJS)
	rm -rf $(DESTDIR)
