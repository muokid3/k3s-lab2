DIRS := $(shell find -maxdepth 1 ! -path . -type d)

.PHONY: all $(DIRS)

all: $(DIRS)		

$(DIRS):
	+$(MAKE) -C $@
