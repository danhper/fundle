buitlin printf '[Downloading fundle ...]'
builtin test -z "$XDG_CONFIG_HOME";
  and builtin set XDG_CONFIG_HOME ~/.config;
command mkdir -p $XDG_CONFIG_HOME/fish/functions;
command curl -sfL https://git.io/fundle > $XDG_CONFIG_HOME/fish/functions/fundle.fish;
  and fish -c "fundle install";
  and builtin exec fish;
# leave the semicolons at the end of the lines, they are needed by eval
