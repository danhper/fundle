export XDG_CONFIG_HOME ?= $(HOME)/.config

FISHTAPE = $(XDG_CONFIG_HOME)/fish/functions/fishtape.fish

test: $(FISHTAPE)
	fish -c 'fishtape test/*_test.fish'

$(FISHTAPE):
	./install-fishtape.sh

.PHONY: test
