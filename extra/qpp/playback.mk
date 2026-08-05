include common_qpp.mk

CFLAGS += -Ilib/libplayback/public -Ilib/libqpp/public

LDFLAGS += -L./lib/libplayback -L./lib/libqpp

LDLIBS += \
	-lplayback \
	-lqpp \
	-lslog2 \
	-lsocket \
	-ljson

PLAYBACK_CONNECTOR = playback/playback-connector/playback-connector
PLAYBACK_RECORDER = playback/playback-connector/playback-recorder
PLAYBACK_TOOL = playback/playback-tool/playback-tool

PLAYBACK_CONNECTOR_OBJS := \
	playback/playback-connector/commandline.o \
	playback/playback-connector/connector.o \
	playback/playback-connector/signal_writer.o \
	playback/playback-connector/util/json.o \
	playback/playback-connector/playback-connector-main.o

PLAYBACK_RECORDER_OBJS := \
	playback/playback-recorder/index_queue.o \
	playback/playback-recorder/initialization.o \
	playback/playback-recorder/initutils.o \
	playback/playback-recorder/nameutils.o \
	playback/playback-recorder/recorder.o \
	playback/playback-recorder/treewalk.o \
	playback/playback-recorder/writer.o \
	playback/playback-recorder/playback-recorder-main.o

PLAYBACK_TOOL_OBJS := \
	playback/playback-tool/circular_buffer.o \
	playback/playback-tool/commandline.o \
	playback/playback-tool/event_parser.o \
	playback/playback-tool/playback-tool-main.o

ALL_OBJS := \
	$(PLAYBACK_CONNECTOR_OBJS) \
	$(PLAYBACK_RECORDER_OBJS) \
	$(PLAYBACK_TOOL_OBJS)

TARGETS := \
	$(PLAYBACK_CONNECTOR) \
	$(PLAYBACK_RECORDER) \
	$(PLAYBACK_TOOL) \

all: $(TARGETS)

$(eval $(call build_binary,$(PLAYBACK_CONNECTOR),$(PLAYBACK_CONNECTOR_OBJS)))
$(eval $(call build_binary,$(PLAYBACK_RECORDER),$(PLAYBACK_RECORDER_OBJS)))
$(eval $(call build_binary,$(PLAYBACK_TOOL),$(PLAYBACK_TOOL_OBJS)))

install: all
	install -d $(DESTDIR)/usr/bin
	install -d $(DESTDIR)/etc/signal_framework

	install -m 755 $(TARGETS) $(DESTDIR)/usr/bin/
	install -m 755 $(addsuffix .sym,$(TARGETS)) $(DESTDIR)/usr/bin/

	install -m 644 playback/playback-recorder/etc/playback-recorder.json $(DESTDIR)/etc/signal_framework
	install -m 644 playback/playback-connector/etc/playback-connector.json $(DESTDIR)/etc/signal_framework
	install -m 644 playback/playback-tool/etc/sample-playback.jsonl $(DESTDIR)/etc/signal_framework

clean:
	rm -f $(TARGETS) $(addsuffix .sym,$(TARGETS)) $(ALL_OBJS)
	rm -rf $(DESTDIR)
