echo "[Downloading fundle ...]";
test -z "$XDG_CONFIG_HOME"; and set XDG_CONFIG_HOME ~/.config;
mkdir -p $XDG_CONFIG_HOME/fish/functions;
curl -sfL https://git.io/fundle > $XDG_CONFIG_HOME/fish/functions/fundle.fish; and fish -c "fundle install"; and exec fish;
# leave the semicolons at the end of the lines, they are needed by eval
