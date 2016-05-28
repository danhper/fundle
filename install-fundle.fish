echo "[Downloading fundle ...]";
mkdir -p ~/.config/fish/functions;
curl -sfL https://git.io/fundle > ~/.config/fish/functions/fundle.fish; and fish -c "fundle install"; and exec fish;
# leave the semicolons at the end of the lines, they are needed by eval
