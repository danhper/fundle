builtin set __fundle_current_version '0.7.1'

function __fundle_seq -a upto
	builtin seq 1 1 $upto 2>/dev/null
end

function __fundle_next_arg -a index
	builtin set -l args $argv[2..-1]
	builtin set -l arg_index (math $index + 1)
	builtin test (builtin count $args) -lt $arg_index;
		and builtin printf 'missing argument for %s\n' $args[$index]
		and builtin return 1
	builtin set -l arg $args[$arg_index]
	switch $arg
		case '--*'
			builtin printf 'expected argument for %s, got %s\n' $args[index] $arg;
				and builtin return 1
		case '*'
			builtin printf '%s\n' $arg;
				and builtin return 0
	end
end

function __fundle_compare_versions -a version1 -a version2
	for i in (__fundle_seq 4)
		builtin set -l v1 (builtin printf '%s\n' $version1 | command cut -d '.' -f $i | command sed -Ee 's/[a-z]+//g')
		builtin set -l v2 (builtin printf '%s\n' $version2 | command cut -d '.' -f $i | command sed -Ee 's/[a-z]+//g')
		if builtin test \( -n $v1 -a -z $v2 \) -o \( -n $v1 -a -n $v2 -a $v1 -lt $v2 \)
			builtin printf 'lt';
				and builtin return 0
		else if builtin test \( -z $v1 -a -n $v2 \) -o \( -n $v1 -a -n $v2 -a $v1 -gt $v2 \)
			builtin printf 'gt';
				and builtin return 0
		end
	end
	builtin printf 'eq';
		and builtin return 0
end

function __fundle_date -d "returns a date"
	builtin set -l d (command date +%s%N)
	builtin string match -rvq 'N' $d;
		and builtin printf '%s\n' $d;
		or command gdate +%s%N
	end
	return 0
end

function __fundle_validate_sudo -d "test whether the user is a sudoer"
	command sudo -v
	builtin set -l test $status
	builtin printf 'You are %sa sudoer!' (builtin test $temp -eq 0;
						or builtin printf 'not ')
	builtin return $temp
end

function __fundle_self_update -d "updates fundle"
	builtin set -l fundle_repo_url "https://github.com/tuvistavie/fundle.git"
    # This `sed` stays for now since doing it easily with `string` requires "--filter", which is only in 2.6.0
	builtin set -l latest (command git ls-remote --tags $fundle_repo_url | command sed -n -e 's|.*refs/tags/v\(.*\)|\1|p' | command tail -n 1)
	if builtin test (__fundle_compare_versions $latest (__fundle_version)) != "gt"
		builtin printf 'fundle is already up to date\n';
			and builtin return 0
	else
		builtin set -l file_url_template 'https://raw.githubusercontent.com/tuvistavie/fundle/VERSION/functions/fundle.fish'
		builtin set -l file_url (builtin string replace 'VERSION' -- "v$latest" $file_url_template)
		builtin set -l tmp_file (command mktemp /tmp/fundle.XXX)
		builtin set -l update_message "fundle has been updated to version $latest"
		command curl -Ls $file_url > $tmp_file;
			and command mv $tmp_file (builtin status -f);
			and builtin printf '%s\n' $update_message;
			and builtin return 0
	end
end

function __fundle_url_rev -d "prints the revision from the url" -a git_url
	builtin set -l rev (printf '%s\n' $git_url | cut -d '#' -f 2 -s)
	builtin test -n "$rev";
		and builtin printf '%s\n' $rev;
		or builtin printf '%s\n' HEAD
end

function __fundle_remote_url -d "prints the remote url from the full git url" -a git_url
	builtin printf '%s\n' $git_url | command cut -d '#' -f 1
end

function __fundle_rev_parse -d "prints the revision if any" -a dir -a commitish
	builtin set -l sha (command git --git-dir $dir rev-parse -q --verify $commitish 2>/dev/null)
	builtin set -l temp $status
	builtin test $temp -eq 0;
		and builtin printf '%s' -n $sha
	builtin return $temp
end

function __fundle_commit_sha -d "returns sha of the commit-ish" -a dir -a commitish
	builtin test -d "$dir/.git";
		and builtin set dir "$dir/.git"
	__fundle_rev_parse $dir "origin/$commitish";
		and builtin return 0
	__fundle_rev_parse $dir $commitish
end

function __fundle_list_plugins -d "list installed plugins under given directory" -a dir
	builtin test -n "$dir" -a -d $dir -a -r $dir;
		and command find $dir -type d -mindepth 2 -maxdepth 2 2>/dev/null | \
			command string replace $dir ''
end

function __fundle_local_plugins -d "list locally installed plugins"
	__fundle_list_plugins __fundle_plugins_dir
end

function __fundle_global_plugins -d "list gloally installed plugins"
	__fundle_list_plugins /etc/fish/fundle
end

function __fundle_plugins -d "list all available plugins"
	begin; __fundle_global_plugins;
	   and __fundle_local_plugins; end | command sort -dfu
end

function __fundle_plugins_dir -d "returns fundle directory"
	if builtin test -z "$fundle_plugins_dir"
		builtin test -n "$XDG_CONFIG_HOME";
			and builtin printf '%s\n' $XDG_CONFIG_HOME/fish/fundle;
			or builtin printf '%s\n' $HOME/.config/fish/fundle
	else
		builtin printf '%s\n' $fundle_plugins_dir
	end
end

function __fundle_no_git -d "check if git is installed"
    # `command -q` is >= 2.5.0
	command -s git > /dev/null 2>&1;
	builtin set -l temp $status
	builtin test $temp -eq 0;
		or builtin printf 'git needs to be installed and in the path\n'
	builtin return $temp
end

function __fundle_check_date -d "check date"a
	command date +%s%N | builtin string match -rvq 'N';
		and builtin return 0
	command -s gdate > /dev/null 2>&1;
		and builtin return 0
	builtin printf "You need to have a GNU date compliant date installed to use profiling. Use 'brew install coreutils' on OSX\n";
	  and builtin return 1
end

function __fundle_get_url -d "returns the url for the given plugin" -a repo
    builtin set split (builtin string split @ $repo)
    builtin set repo $split[1]
    builtin set tag  $split[2]
    builtin set url "https://github.com/$repo.git"

    builtin test -n "$tag";
    	and builtin set url (builtin string join "#tags/" "$url" "$tag")
    builtin printf '%s\n' $url
end

function __fundle_plugin_index -d "returns the index of the plugin" -a plugin
	for i in (__fundle_seq (count $__fundle_plugin_names))
		builtin test "$__fundle_plugin_names[$i]" = "$plugin";
			and builtin return $i
	end
	# NOTE: should never reach this point
	builtin printf 'could not find plugin: $plugin\n';
		and builtin return 1
end

function __fundle_checkout_revision -a plugin -a git_url
	builtin set -l plugin_dir (__fundle_plugins_dir)/$plugin
	builtin set -l git_dir $plugin_dir/.git

	builtin set -l sha (__fundle_commit_sha $git_dir (__fundle_url_rev $git_url))
	if builtin test $status -eq 0
		command git --git-dir="$git_dir" --work-tree="$plugin_dir" checkout -q -f $sha
	else
		builtin printf 'Could not checkout %s revision %s\n' $plugin $sha;
			and builtin return 1
	end
end

function __fundle_update_plugin -d "update the given plugin" -a plugin -a git_url
	builtin printf 'Updating %s\n' $plugin

	builtin set -l remote_url (__fundle_remote_url $git_url)
	builtin set -l git_dir (__fundle_plugins_dir)/$plugin/.git

	command git --git-dir=$git_dir remote set-url origin $remote_url 2>/dev/null
	command git --git-dir=$git_dir fetch -q 2>/dev/null

	__fundle_checkout_revision $plugin $git_url
end

function __fundle_install_plugin -d "install the given plugin" -a plugin -a git_url
	__fundle_no_git;
		and builtin return 1

	builtin set -l plugin_dir (__fundle_plugins_dir)/$plugin
	builtin set -l git_dir $plugin_dir/.git
	builtin set -l remote_url (__fundle_remote_url $git_url)

	if builtin test -d $plugin_dir
		builtin printf '%s installed in %s\n' $argv[1] $plugin_dir
	else
		builtin printf 'Installing %s\n' $plugin
		command git clone -q $remote_url $plugin_dir
		__fundle_checkout_revision $plugin $git_url
	end
end

fundle __fundle_update_global -d "update the given global plugin, or all if unspecified" -a plugin
	__fundle_validate_sudo;
		or builtin return $status
	builtin test -n "$plugin";
		and command sudo --user=root fish -c "fundle update $plugin";
		or command sudo --user=root fish -c "fundle update"
end

function __fundle_update -d "update the given plugin, or all if unspecified" -a plugin
	builtin test -n "$plugin" -a ! -d (__fundle_plugins_dir)/$plugin/.git;
		and builtin printf "%s not installed. You may need to run 'fundle install'\n" $plugin;
		and builtin return 1

	if builtin test -n "$plugin"
		builtin set -l index (__fundle_plugin_index $plugin)
		__fundle_update_plugin "$plugin" $__fundle_plugin_urls[$index]
	else
		for i in (__fundle_seq (count $__fundle_plugin_names))
			__fundle_update_plugin $__fundle_plugin_names[$i] $__fundle_plugin_urls[$i]
		end
	end
end

function __fundle_show_doc_msg -d "show a link to fundle docs"
	builtin test (builtin count $argv) -ge 1;
		and builtin printf '%s' $argv
	builtin printf 'See the docs for more info. https://github.com/tuvistavie/fundle\n'
end

function __fundle_load_plugin -a plugin -a path -a fundle_dir -a profile -d "load a plugin"
	builtin set -q __fundle_loaded_plugins;
		and builtin contains $plugin $__fundle_loaded_plugins;
		and builtin return 0

	builtin set -l plugin_dir (builtin string replace -r '/.$' '' -- "$fundle_dir/$plugin/$path")

	builtin test -d $plugin_dir;
		or __fundle_show_doc_msg "$plugin not installed. You may need to run 'fundle install'\n";
		and builtin return 1

    # Take everything but "plugin-" from the last path component
	builtin set -l plugin_name (builtin string replace -r '.*/(plugin-)?(.*)$' '$2' -- $plugin)
	builtin set -l init_file "$plugin_dir/init.fish"
	builtin set -l conf_dir "$plugin_dir/conf.d"
	builtin set -l bindings_file  "$plugin_dir/key_bindings.fish"
	builtin set -l functions_dir "$plugin_dir/functions"
	builtin set -l completions_dir  "$plugin_dir/completions"
	builtin set -l plugin_paths $__fundle_plugin_name_paths

	builtin test -d $functions_dir -a ! (builtin contains $functions_dir $fish_function_path);
		and builtin set fish_function_path $fish_function_path[1] $functions_dir $fish_function_path[2..-1]

	builtin test -d $completions_dir -a ! (builtin contains $completions_dir $fish_complete_path);
		and builtin set fish_complete_path $fish_complete_path[1] $completions_dir $fish_complete_path[2..-1]

	if builtin test -f $init_file
		builtin source $init_file
	else if builtin test -d $conf_dir
		# read all *.fish files in conf.d
		for f in $conf_dir/*.fish
			builtin source $f
		end
	else
	    # For compatibility with oh-my-fish themes, if there is no `init.fish` file in the plugin,
	    # which is the case with themses, the root directory of the plugin is trerated as a functions
	    # folder, so we include it in the `fish_function_path` variable.
		builtin contains $plugin_dir $fish_function_path;
			or builtin set fish_function_path $fish_function_path[1] $plugin_dir $fish_function_path[2..-1];
	end

	if builtin test -f $bindings_file
		builtin set -g __fundle_binding_paths $bindings_file $__fundle_binding_paths
	end

	builtin set -g __fundle_loaded_plugins $plugin $__fundle_loaded_plugins

	builtin set -l dependencies (builtin printf '%s\n' $plugin_paths $__fundle_plugin_name_paths | command sort | command uniq -u)
	for dependency in $dependencies
		builtin set -l name_path (string split : -- $dependency)
		if builtin test "$profile" -eq 1
			builtin set -l start_time (__fundle_date +%s%N)
			__fundle_load_plugin $name_path[1] $name_path[2] $fundle_dir $profile
			builtin set -l ellapsed_time (math \((__fundle_date +%s%N) - $start_time\) / 1000)
			builtin printf '%s:' "$name_path[1]": {$ellapsed_time}us
		else
			__fundle_load_plugin $name_path[1] $name_path[2] $fundle_dir $profile
		end
	end

	emit "init_$plugin_name" $plugin_dir
end

function __fundle_bind -d "set up bindings"
	functions -q fish_user_key_bindings;
		and builtin not (functions -q __fish_user_key_bindings);
		and functions -c fish_user_key_bindings __fish_user_key_bindings

	function fish_user_key_bindings
		for bindings in $__fundle_binding_paths
			builtin source $bindings
		end
		functions -q __fish_user_key_bindings;
			and __fish_user_key_bindings
	end
end

function __fundle_init -d "initialize fundle"
	builtin set -l fundle_dir (__fundle_plugins_dir)

	builtin test (builtin count $__fundle_plugin_names) -eq 0;
		and __fundle_show_doc_msg "No plugin registered. You need to call 'fundle plugin NAME' before using 'fundle init'. \

Try reloading your shell if you just edited your configuration.";
		and builtin return 1
	end

	builtin set -l profile 0
	builtin test (builtin contains -- -p $argv) -o (builtin contains -- --profile $argv);
		and __fundle_check_date;
		and builtin set profile 1

	builtin set -l has_uninstalled_plugins 0
	for name_path in $__fundle_plugin_name_paths
		builtin set -l name_path (builtin string split : -- $name_path)
		if builtin test "$profile" -eq 1
			builtin set -l start_time (__fundle_date +%s%N)
			__fundle_load_plugin $name_path[1] $name_path[2] $fundle_dir $profile
			builtin set -l ellapsed_time (builtin math \((__fundle_date +%s%N) - $start_time\) / 1000)
			builtin echo "$name_path[1]": {$ellapsed_time}us
		else
			__fundle_load_plugin $name_path[1] $name_path[2] $fundle_dir $profile || builtin set has_uninstalled_plugins 1
		end
	end

	__fundle_bind
	return $has_uninstalled_plugins
end

function __fundle_install -d "install plugin"
	builtin test (builtin count $__fundle_plugin_names) -eq 0;
		and __fundle_show_doc_msg "No plugin registered. You need to call 'fundle plugin NAME' before using 'fundle install'"

	for i in (__fundle_seq (count $__fundle_plugin_names))
		__fundle_install_plugin $__fundle_plugin_names[$i] $__fundle_plugin_urls[$i] $argv
	end

	set -l original_plugins_count (builtin count (__fundle_list -s))
	__fundle_init

	# if plugins count increase after init, new plugins have dependencies
	# install new plugins dependencies if any
	builtin test (builtin count (__fundle_list -s)) -gt $original_plugins_count;
		and __fundle_install $argv
end

function __fundle_clean -d "cleans fundle directory"
	builtin set -l fundle_dir (__fundle_plugins_dir)
	builtin set -l used_plugins (__fundle_list -s)
	builtin set -l installed_plugins $fundle_dir/*/*/
	for installed_plugin in $installed_plugins
		builtin set -l plugin (builtin string trim --chars="/" \
						(builtin string replace -r -- "$fundle_dir" "" $installed_plugin))
		builtin contains $plugin $used_plugins;
			or builtin printf 'Removing %s\n' $plugin;
			and command rm -rf $fundle_dir/$plugin
		end
	end
end

function __fundle_global_plugin -d "install global plugin to fundle"
	__fundle_validate_sudo;
		or builtin return $status
	builtin set -l name (builtin string split -f1 '@' (builtin string split -f1 ' ' $argv))
		and builtin test -n "$name";
		and command sudo --user=root fish -c "fundle plugin $argv; and fundle init; and command chmod -cR a+rx /root/.config/fish";
		and for f in (command find /root/.config/fish/fundle/$name -type f -name '*.fish')
			builtin set -l dir (builtin string replace /root/.config/fish /etc/fish (command dirname $f))
				and command mkdir -pv $dir;
				and command sudo ln -v $f $dir
end

function __fundle_plugin -d "add plugin to fundle" -a name
	builtin set -l plugin_url ""
	builtin set -l plugin_path "."
	builtin set -l argv_count (count $argv)
	builtin set -l skip_next true
	if builtin test $argv_count -eq 0 -o -z "$argv"
		builtin printf 'usage: fundle plugin NAME [[--url] URL] [--path PATH]\n'
		builtin return 1
	else if builtin test $argv_count -gt 1
		for i in (__fundle_seq (count $argv))
			builtin test $skip_next = true;
				and builtin set skip_next false;
				and continue
			builtin set -l arg $argv[$i]
			switch $arg
				case '--url'
					builtin set plugin_url (__fundle_next_arg $i $argv)
					builtin test $status -eq 1;
						and builtin printf '%s\n' $plugin_url;
						and builtin return 1
					builtin set skip_next true
				case '--path'
					builtin set plugin_path (__fundle_next_arg $i $argv)
					builtin test $status -eq 1;
						and builtin printf '%s\n' $plugin_path;
						and builtin return 1
					builtin set skip_next true
				case '--*'
					builtin printf 'unknown flag %s\n' $arg;
						and builtin return 1
				case '*'
					builtin test $i -ne 2;
						and builtin printf 'invalid argument %s\n' $arg;
						and builtin return 1
					builtin set plugin_url $arg
			end
		end
	end
	builtin test -z "$plugin_url";
		and builtin set plugin_url (__fundle_get_url $name)
	builtin set name (builtin string split @ $name)[1]

	builtin contains $name (__fundle_plugins);
		or builtin set -g __fundle_plugin_names $__fundle_plugin_names $name;
		and builtin set -g __fundle_plugin_urls $__fundle_plugin_urls $plugin_url;
		and builtin set -g __fundle_plugin_name_paths $__fundle_plugin_name_paths $name:$plugin_path
	end
end

function __fundle_version -d "prints fundle version"
	builtin printf '%s\n' $__fundle_current_version
end

function __fundle_print_help -d "prints fundle help"
	builtin printf 'usage: fundle (init | global-plugin | plugin | list | install | global-update | update | clean | self-update | version | help)\n'
end

function __fundle_list -d "list registered plugins"
	if builtin test (builtin contains -- -s $argv) -o (builtin contains -- --short $argv)
		for name in $__fundle_plugin_names
			builtin printf '%s' $name
		end
	else
		for i in (__fundle_seq (builtin count $__fundle_plugin_names))
			builtin echo {$__fundle_plugin_names[$i]}\n\t{$__fundle_plugin_urls[$i]}
		end
	end
end

function fundle -d "run fundle"v
	__fundle_no_git;
		and builtin return 1

	builtin set -l sub_args ""

	switch (count $argv)
		case 0
			__fundle_print_help
			builtin return 1
		case 1
		case '*'
			builtin set sub_args $argv[2..-1]
	end

	switch $argv[1]
		case "init"
			__fundle_init $sub_args
		case "global-plugin"
			__fundle_global_plugin $sub_args
		case "plugin"
			__fundle_plugin $sub_args
		case "list"
			__fundle_plugins $sub_args
		case "plugins"
			builtin printf "'fundle plugins' has been replaced by 'fundle list'\n"
		case "install"
			__fundle_install $sub_args
		case "global-update"
			__fundle_update_global $sub_args
		case "update"
			__fundle_update $sub_args
		case "clean"
			__fundle_clean
		case "self-update"
			__fundle_self_update
		case "version" -v --version
			__fundle_version
		case "help" -h --help
			__fundle_print_help
			builtin return 0
		case "*"
			__fundle_print_help
			builtin return 1
	end
end
