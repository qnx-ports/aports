include common_qpp.mk

CFLAGS += -Ilib/libqpp/public -Isignal-framework/connectors/echo-actuator

LDFLAGS += -L./lib/libqpp

LDLIBS += \
	-lqpp \
	-ljson \
	-lslog2

ECHO_ACTUATOR = signal-framework/connectors/echo-actuator/echo-actuator

ALL_OBJS := \
	signal-framework/connectors/echo-actuator/connector.o \
	signal-framework/connectors/echo-actuator/commandline.o \
	signal-framework/connectors/echo-actuator/util/json.o \
	signal-framework/connectors/echo-actuator/echo-actuator-main.o

TARGETS := $(ECHO_ACTUATOR)

all: $(TARGETS)

$(eval $(call build_binary,$(ECHO_ACTUATOR),$(ALL_OBJS)))

install: all
	install -d $(DESTDIR)/usr/bin
	install -d $(DESTDIR)/etc/signal_framework

	install -m 755 $(TARGETS) $(DESTDIR)/usr/bin/
	install -m 755 $(addsuffix .sym,$(TARGETS)) $(DESTDIR)/usr/bin/

	install -m 644 signal-framework/connectors/echo-actuator/etc/echo-actuator.json $(DESTDIR)/etc/signal_framework

clean:
	rm -f $(TARGETS) $(addsuffix .sym,$(TARGETS)) $(ALL_OBJS)
	rm -rf $(DESTDIR)
