echo "[Downloading fundle ...]";
mkdir -p ~/.config/fish/functions;
curl -#fL https://git.io/fundle > ~/.config/fish/functions/fundle.fish; and fish -c "fundle install"; and exec fish

