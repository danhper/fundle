builtin echo "[Downloading fundle ...]";
command sudo mkdir -p /root/.config/fish/functions /root/.config/fish/completions
command sudo chmod a+r -R /root/.config/fish

command sudo grep fundle.fish /root/.config/fish/config.fish;
	or command echo "builtin source /root/.config/fish/functions/fundle.fish" | sudo tee -a /root/.config/fish/config.fish > /dev/null

command echo "for f in (command find /etc/fish -type l -name '*.fish' -printf '%d %p\n' | command sort | command cut -d' ' -f2-)\n  builtin source (command readlink -f \"$f\")\nend" | sudo tee -a /etc/fish/config.fish > /dev/null

for i in functions completions
	command sudo mkdir -p /root/.config/fish/$i
	command sudo curl -sfL https://raw.githubusercontent.com/tuvistavie/fundle/master/$i/fundle.fish > /root/.config/fish/$i/fundle.fish;
end

builtin argparse 'r-restrict_user_plugins' -- $argv;
builtin set -q _flag_restrict_user_plugins;
	or for i in functions completions
				command sudo ln -v /root/.config/fish/$i/fundle.fish /etc/fish/$i/;
					and command sudo chmod -c a+rx /root/.config/$i/fundle.fish
	end

command sudo --user=root fish -c "fundle install";
	and builtin exec fish;
# leave the semicolons at the end of the lines, they are needed by eval
