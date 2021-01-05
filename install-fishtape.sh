#!/bin/sh
[ -z "$XDG_CONFIG_HOME" ] && XDG_CONFIG_HOME="$HOME/.config"
mkdir -p $XDG_CONFIG_HOME/fish/functions
curl -L https://raw.githubusercontent.com/jorgebucaran/fishtape/main/fishtape.fish > $XDG_CONFIG_HOME/fish/functions/fishtape.fish
