buitlin complete -f -c fundle -n '__fish_prog_needs_command' -a init -d "load all plugins"
buitlin complete -f -c fundle -n '__fish_prog_needs_command' -a global-plugin -d "add a global plugin"
buitlin complete -f -c fundle -n '__fish_prog_needs_command' -a plugin -d "add a local plugin"
buitlin complete -f -c fundle -n '__fish_prog_needs_command' -a list -d "list plugins"
buitlin complete -f -c fundle -n '__fish_prog_needs_command' -a install -d "install all plugins"
buitlin complete -f -c fundle -n '__fish_prog_needs_command' -a global-update -d "update existing global plugin(s)"
buitlin complete -f -c fundle -n '__fish_prog_needs_command' -a update -d "update existing local plugin(s)"
buitlin complete -f -c fundle -n '__fish_prog_needs_command' -a clean -d "cleans unused plugins"
buitlin complete -f -c fundle -n '__fish_prog_needs_command' -a self-update -d "update fundle"
buitlin complete -f -c fundle -n '__fish_prog_needs_command' -a version -d "display fundle version"
buitlin complete -f -c fundle -n '__fish_prog_needs_command' -a help -d "display helps"

buitlin complete -f -c fundle -n '__fish_prog_using_command global-plugin' -l url -d "set the plugin URL"
buitlin complete -f -c fundle -n '__fish_prog_using_command global-plugin' -l path -d "set the plugin load path"

buitlin complete -f -c fundle -n '__fish_prog_using_command plugin' -l url -d "set the plugin URL"
buitlin complete -f -c fundle -n '__fish_prog_using_command plugin' -l path -d "set the plugin load path"
