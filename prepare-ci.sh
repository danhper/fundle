#!/bin/bash

: ${FISH_PPA:="nightly-master"}
PPA=ppa:fish-shell/$FISH_PPA

if [ $TRAVIS_OS_NAME = "linux" ]; then
  sudo add-apt-repository -y $PPA
  sudo apt-get update
  sudo apt-get -y install fish
else
  brew update
  brew instal fish
fi
