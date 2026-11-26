# Prepare the test data after cloning: fetch every artifact, build those the
# annex cannot fetch. A failing directory does not stop the others

DIRS := $(patsubst %/Makefile,%,$(shell grep -l '^include ../common.mk' */Makefile))

all: $(DIRS)

annex:
	git config annex.private true
	git annex init
	-git fetch origin git-annex

$(DIRS): annex
	-$(MAKE) -k -C $@ setup

.PHONY: all annex $(DIRS)
