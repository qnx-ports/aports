COMMON_DIR:= $(dir $(lastword $(MAKEFILE_LIST)))

.PHONY: all

all:
	$(MAKE) -f $(COMMON_DIR)libplayback.mk
	$(MAKE) -f $(COMMON_DIR)libqpp.mk
	$(MAKE) -f $(COMMON_DIR)samples.mk
	$(MAKE) -f $(COMMON_DIR)signal_framework.mk
	$(MAKE) -f $(COMMON_DIR)playback.mk
	$(MAKE) -f $(COMMON_DIR)qpp.mk

install: all
	$(MAKE) -f $(COMMON_DIR)samples.mk install
	$(MAKE) -f $(COMMON_DIR)signal_framework.mk install
	$(MAKE) -f $(COMMON_DIR)playback.mk install
	$(MAKE) -f $(COMMON_DIR)qpp.mk install

clean:
	$(MAKE) -f $(COMMON_DIR)libplayback.mk clean
	$(MAKE) -f $(COMMON_DIR)libqpp.mk clean
	$(MAKE) -f $(COMMON_DIR)samples.mk clean
	$(MAKE) -f $(COMMON_DIR)signal_framework.mk clean
	$(MAKE) -f $(COMMON_DIR)playback.mk clean
	$(MAKE) -f $(COMMON_DIR)qpp.mk clean
