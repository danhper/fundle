#!/bin/sh
[ -z "$XDG_CONFIG_HOME" ] && XDG_CONFIG_HOME="~/.config"
mkdir -p $XDG_CONFIG_HOME/fish/functions
curl -L https://raw.githubusercontent.com/tuvistavie/fishtape/master/fishtape.fish > $XDG_CONFIG_HOME/fish/functions/fishtape.fish
