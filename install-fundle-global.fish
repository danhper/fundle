builtin echo "[Downloading fundle ...]";
command mkdir -p /root/.config/fish/functions /root/.config/fish/completions
command grep fundle.fish /root/.config/fish/config.fish;
	or command sudo echo "builtin source /root/.config/fish/functions/fundle.fish" >> /root/.config/fish/config.fish
command sudo echo "for f in (command find /etc/fish -type l -name '*.fish' -printf '%d %p\n' | command sort | command cut -d' ' -f2-)\n	builtin source (command readlink -f \"$f\")\nend" >> /etc/fish/config.fish
for i in functions completions
	command mkdir -p /root/.config/fish/$i
	command sudo curl -sfL https://raw.githubusercontent.com/tuvistavie/fundle/master/$i/fundle.fish > /root/.config/fish/$i/fundle.fish;
end
builtin fish_opt -s r --long-only restrict_user_plugins;
		or for i in functions completions
					command sudo ln -v /root/.config/fish/$i/fundle.fish /etc/fish/$i/;
						and command chmod -c a+rx /root/.config/$i/fundle.fish
				end
command sudo --user=root fish -c "fundle install";
	and builtin exec fish;
# leave the semicolons at the end of the lines, they are needed by eval
