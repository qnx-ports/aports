include common_qpp.mk

SAMPLE_SIGNAL_CONSUMER = signal-framework/sample/sample-signal-consumer/sample-signal-consumer
SAMPLE_SIGNAL_PUBLISHER = signal-framework/sample/sample-signal-publisher/sample-signal-publisher
SAMPLE_MESSAGE_SUBSCRIBER = message-framework/samples/sample-message-subscriber/sample-message-subscriber
SAMPLE_MESSAGE_PUBLISHER = message-framework/samples/sample-message-publisher/sample-message-publisher

SAMPLE_SIGNAL_CONSUMER_OBJS := $(SAMPLE_SIGNAL_CONSUMER)-main.o
SAMPLE_SIGNAL_PUBLISHER_OBJS := $(SAMPLE_SIGNAL_PUBLISHER)-main.o
SAMPLE_MESSAGE_SUBSCRIBER_OBJS := $(SAMPLE_MESSAGE_SUBSCRIBER)-main.o
SAMPLE_MESSAGE_PUBLISHER_OBJS := $(SAMPLE_MESSAGE_PUBLISHER)-main.o

ALL_OBJS := \
    $(SAMPLE_SIGNAL_CONSUMER_OBJS) \
    $(SAMPLE_SIGNAL_PUBLISHER_OBJS) \
    $(SAMPLE_MESSAGE_SUBSCRIBER_OBJS) \
    $(SAMPLE_MESSAGE_PUBLISHER_OBJS)

TARGETS := \
	$(SAMPLE_SIGNAL_CONSUMER) \
	$(SAMPLE_SIGNAL_PUBLISHER) \
	$(SAMPLE_MESSAGE_SUBSCRIBER) \
	$(SAMPLE_MESSAGE_PUBLISHER)

all: $(TARGETS)

$(eval $(call build_binary,$(SAMPLE_SIGNAL_CONSUMER),$(SAMPLE_SIGNAL_CONSUMER_OBJS)))
$(eval $(call build_binary,$(SAMPLE_SIGNAL_PUBLISHER),$(SAMPLE_SIGNAL_PUBLISHER_OBJS)))
$(eval $(call build_binary,$(SAMPLE_MESSAGE_SUBSCRIBER),$(SAMPLE_MESSAGE_SUBSCRIBER_OBJS)))
$(eval $(call build_binary,$(SAMPLE_MESSAGE_PUBLISHER),$(SAMPLE_MESSAGE_PUBLISHER_OBJS)))

install: all
	install -d $(DESTDIR)/usr/bin

	install -m 755 $(TARGETS) $(DESTDIR)/usr/bin/
	install -m 755 $(addsuffix .sym,$(TARGETS)) $(DESTDIR)/usr/bin/

clean:
	rm -f $(TARGETS) $(addsuffix .sym,$(TARGETS)) $(ALL_OBJS)
	rm -rf $(DESTDIR)
