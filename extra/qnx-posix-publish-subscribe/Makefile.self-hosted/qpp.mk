COMMON_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

include $(COMMON_DIR)common_qpp.mk

SERVICE_NAME = "QNX POSIX PubSub Service"
NAME="qpp"

CFLAGS += -Ilib/libqpp/public
CFLAGS += -DSERVICE_NAME=\"$(SERVICE_NAME)\"

QPP = qpp/qpp

TARGETS = $(QPP)

LDFLAGS += -L./lib/libqpp

LDLIBS += \
	-lqpp \
	-ljson \
	-lslog2

ALL_OBJS := \
	qpp/catalog.o \
	qpp/directory.o \
	qpp/initialization.o \
	qpp/inode.o \
	qpp/ioclose.o \
	qpp/iomknod.o \
	qpp/iomknod_read_only.o \
	qpp/ionotify.o \
	qpp/ioopen.o \
	qpp/ioread_dir.o \
	qpp/ioread.o \
	qpp/ioread_text.o \
	qpp/ioseek.o \
	qpp/iounlink.o \
	qpp/iounlink_read_only.o \
	qpp/iowrite.o \
	qpp/iowrite_text.o \
	qpp/metadata.o \
	qpp/node.o \
	qpp/ocb.o \
	qpp/tree.o \
	qpp/utils/base64.o \
	qpp/utils/utils.o \
	qpp/value.o \
	qpp/main.o

all: $(TARGETS)

$(eval $(call build_binary,$(QPP),$(ALL_OBJS)))

install: all
	install -d $(DESTDIR)/usr/bin

	install -m 755 $(TARGETS) $(DESTDIR)/usr/bin/
	install -m 755 $(addsuffix .sym,$(TARGETS)) $(DESTDIR)/usr/bin/

	install -m 644 signal-framework/signal-service/etc/robot_catalog.json $(DESTDIR)/etc/signal_framework
	install -m 644 signal-framework/signal-service/etc/signal_catalog.json $(DESTDIR)/etc/signal_framework

clean:
	rm -f $(TARGETS) $(addsuffix .sym,$(TARGETS)) $(ALL_OBJS)
	rm -rf $(DESTDIR)
