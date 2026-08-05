include common_qpp.mk

CFLAGS += -Ilib/libplayback/public

TARGETS = lib/libplayback/libplayback.a

ALL_OBJS := lib/libplayback/signal_event.o

# Static libraries
$(TARGETS): $(ALL_OBJS)
	$(AR) rcs $@ $^

all: $(TARGETS)

install: all
