export XDG_CONFIG_HOME ?= $(HOME)/.config

FISHTAPE = $(XDG_CONFIG_HOME)/fish/functions/fishtape.fish

# XXX: tests are reusing same tmp directory so run sequentially for now
test: $(FISHTAPE)
	fish -c 'for file in test/*_test.fish; fishtape $$file; end'

$(FISHTAPE):
	./install-fishtape.sh

.PHONY: test
