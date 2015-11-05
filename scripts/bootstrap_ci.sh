#!/usr/bin/env bash
ppa=ppa:fish-shell/${FISH_PPA:-nightly-master}
sudo add-apt-repository -y $ppa
sudo apt-get update
sudo apt-get -y install fish
