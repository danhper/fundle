FISH_PPA ?= nightly-master
PPA = ppa:fish-shell/$(FISH_PPA)

test:
	fish test/runner.fish

prepare:
	sudo add-apt-repository -y $(PPA)
	sudo apt-get update
	sudo apt-get -y install fish
	fish --version

.PHONY: test
