FISHTAPE = $(HOME)/.config/fish/functions/fishtape.fish

test: $(FISHTAPE)
	fish -c 'fishtape test/*_test.fish'

$(FISHTAPE):
	./install-fishtape.sh

.PHONY: test
