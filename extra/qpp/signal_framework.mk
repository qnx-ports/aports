include common_qpp.mk

CFLAGS += -Ilib/libqpp/public

LDLIBS += \
	-ljson \
	-lslog2

COMMON_OBJS := lib/libqpp/*.o

ECHO_ACTUATOR = signal-framework/connectors/echo-actuator/echo-actuator

ALL_OBJS := \
	signal-framework/connectors/echo-actuator/connector.o \
	signal-framework/connectors/echo-actuator/commandline.o \
	signal-framework/connectors/echo-actuator/util/json.o \
	signal-framework/connectors/echo-actuator/echo-actuator-main.o

TARGETS := \
	$(ECHO_ACTUATOR) \

all: $(TARGETS)

$(eval $(call build_binary,$(ECHO_ACTUATOR),$(ALL_OBJS)))

install: all
	install -d $(DESTDIR)/usr/bin
	install -d $(DESTDIR)/etc/signal_framework

	install -m 755 $(TARGETS) $(DESTDIR)/usr/bin/
	install -m 755 $(addsuffix .sym,$(TARGETS)) $(DESTDIR)/usr/bin/
