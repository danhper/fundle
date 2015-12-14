set __fundle_current_version '0.3.0'

function __fundle_seq -a upto
	seq 1 1 $upto ^ /dev/null
end

function __fundle_compare_versions -a version1 -a version2
	for i in (__fundle_seq 3)
		set -l v1 (echo $version1 | cut -d '.' -f $i)
		set -l v2 (echo $version2 | cut -d '.' -f $i)
		if test $v1 -lt $v2
			echo -n "lt"; and return 0
		else if test $v1 -gt $v2
			echo -n "gt"; and return 0
		end
	end
	echo -n "eq"; and return 0
end

function __fundle_profile -d "runs a function in profile mode"
	set -l start_time (date +%s%N)
	eval $argv
	set -l ellapsed_time (math \((date +%s%N) - $start_time\) / 1000)
	echo "$argv": {$ellapsed_time}us
end

function __fundle_self_update -d "updates fundle"
	set -l fundle_repo_url "https://github.com/tuvistavie/fundle.git"
	set -l latest (git ls-remote --tags $fundle_repo_url | sed -n -e 's|.*refs/tags/v\(.*\)|\1|p' | tail -n 1)
	if test (__fundle_compare_versions $latest (__fundle_version)) != "gt"
		echo "fundle is already up to date"; and return 0
	else
		set -l file_url_template 'https://raw.githubusercontent.com/tuvistavie/fundle/VERSION/functions/fundle.fish'
		set -l file_url (echo $file_url_template | sed -e "s/VERSION/v$latest/")
		set -l tmp_file (mktemp)
		set -l update_message "fundle has been updated to version $latest"
		curl -Ls $file_url > $tmp_file; and mv $tmp_file (status -f); and echo $update_message; and return 0
	end
end

function __fundle_url_rev -d "prints the revision from the url" -a git_url
	set -l rev (echo $git_url | cut -d '#' -f 2 -s)
	if test -n "$rev"
		echo $rev
	else
		echo master
	end
end

function __fundle_remote_url -d "prints the remote url from the full git url" -a git_url
	echo $git_url | cut -d '#' -f 1
end

function __fundle_rev_parse -d "prints the revision if any" -a dir -a commitish
	set -l sha (git --git-dir $dir rev-parse -q --verify $commitish ^ /dev/null)
	if test $status -eq 0
		echo $sha
		return 0
	end
	return 1
end

function __fundle_commit_sha -d "returns sha of the commit-ish" -a dir -a commitish
	if test -d "$dir/.git"
		set dir "$dir/.git"
	end
	if __fundle_rev_parse $dir "origin/$commitish"
		return 0
	end
	__fundle_rev_parse $dir $commitish
end

function __fundle_plugins_dir -d "returns fundle directory"
	if test -z "$fundle_plugins_dir"
		echo $HOME/.config/fish/fundle
	else
		echo $fundle_plugins_dir
	end
end

function __fundle_no_git -d "check if git is installed"
	if not which git > /dev/null
		echo "git needs to be installed and in the path"
		return 0
	end
	return 1
end

function __fundle_get_url -d "returns the url for the given plugin" -a repo
	echo "https://github.com/$repo.git"
end

function __fundle_update_plugin -d "update the given plugin" -a git_dir -a remote_url
	git --git-dir=$git_dir remote set-url origin $remote_url ^ /dev/null; and \
	git --git-dir=$git_dir fetch -q ^ /dev/null
end

function __fundle_install_plugin -d "install the given plugin" -a plugin -a git_url
	if __fundle_no_git
		return 1
	end

	set -l plugin_dir (__fundle_plugins_dir)/$plugin
	set -l git_dir $plugin_dir/.git
	set -l remote_url (__fundle_remote_url $git_url)
	set -l upgrade ""

	if begin; contains -- -u $argv; or contains -- --upgrade $argv; end
		set upgrade true
	end

	if test -d $plugin_dir
		if test -n "$upgrade"
			echo "Upgrading $plugin"
			__fundle_update_plugin $git_dir $remote_url
		else
			echo "$argv[1] installed in $plugin_dir"
			return 0
		end
	else
		echo "Installing $plugin"
		git clone -q $remote_url $plugin_dir
	end

	set -l sha (__fundle_commit_sha $git_dir (__fundle_url_rev $git_url))
	if test $status -eq 0
		git --git-dir="$git_dir" --work-tree="$plugin_dir" checkout -q -f $sha
	else
		echo "Could not upgrade $plugin"
		return 1
	end
end

function __fundle_show_doc_msg -d "show a link to fundle docs"
	if test (count $argv) -ge 1
		echo $argv
	end
	echo "See the docs for more info. https://github.com/tuvistavie/fundle"
end

function __fundle_load_plugin -a plugin -a fundle_dir -a profile -d "load a plugin"
	if begin; set -q __fundle_loaded_plugins; and contains $plugin $__fundle_loaded_plugins; end
		return 0
	end

	set -l plugin_dir "$fundle_dir/$plugin"

	if not test -d $plugin_dir
		__fundle_show_doc_msg "$plugin not installed. You may need to run 'fundle install'"
		return 0
	end

	set -l plugin_name (echo $plugin | awk -F/ '{print $NF}' | sed -e s/plugin-//)
	set -l init_file "$plugin_dir/init.fish"
	set -l plugin_file "$plugin_dir/$plugin_name.fish"
	set -l functions_dir "$plugin_dir/functions"
	set -l completions_dir  "$plugin_dir/completions"
	set -l plugins $__fundle_plugin_names

	if begin; test -d $functions_dir; and not contains $functions_dir $fish_function_path; end
		set fish_function_path $functions_dir $fish_function_path
	end

	if begin; test -d $completions_dir; and not contains $completions_dir $fish_complete_path; end
		set fish_complete_path $completions_dir $fish_complete_path
	end

	if test -f $init_file
		source $init_file
	else if test -f $plugin_file
		source $plugin_file
	else
		# read all *.fish files if no init.fish found
		for f in (find $plugin_dir -maxdepth 1 -iname "*.fish")
			source $f
		end
	end

	set -g __fundle_loaded_plugins $plugin $__fundle_loaded_plugins

	set -l dependencies (echo -s \n$plugins \n$__fundle_plugin_names | sed -e '/^$/d' | sort | uniq -u)
	for dependency in $dependencies
		if test $profile -eq 1
			__fundle_profile __fundle_load_plugin $dependency $fundle_dir 1
		else
			__fundle_load_plugin $dependency $fundle_dir 0
		end
	end

	emit "init_$plugin_name" $plugin_dir
end

function __fundle_init -d "initialize fundle"
	set -l fundle_dir (__fundle_plugins_dir)

	if test (count $__fundle_plugin_names) -eq 0
		__fundle_show_doc_msg "No plugin registered. You need to call 'fundle plugin NAME' before using 'fundle init'. \

Try reloading your shell if you just edited your configuration."
		return 1
	end

	set -l profile 0
	if begin; contains -- -p $argv; or contains -- --profile $argv; end
		set profile 1
	end

	for plugin in $__fundle_plugin_names
		if test $profile -eq 1
			__fundle_profile __fundle_load_plugin $plugin $fundle_dir 1
		else
			__fundle_load_plugin $plugin $fundle_dir 0
		end
	end
end

function __fundle_install -d "install plugin"
	if test (count $__fundle_plugin_names) -eq 0
		__fundle_show_doc_msg "No plugin registered. You need to call 'fundle plugin NAME' before using 'fundle install'"
	end

	for i in (__fundle_seq (count $__fundle_plugin_names))
		__fundle_install_plugin $__fundle_plugin_names[$i] $__fundle_plugin_urls[$i] $argv
	end

	set -l original_plugins_count (count (__fundle_plugins -s))
	__fundle_init

	# if plugins count increase after init, new plugins have dependencies
	# install new plugins dependencies if any
	if test (count (__fundle_plugins -s)) -gt $original_plugins_count
		__fundle_install $argv
	end
end

function __fundle_plugin -d "add plugin to fundle" -a name
	set -l plugin_url ""
	switch (count $argv)
		case 0
			echo "plugin needs at least one parameter."
			return 1
		case 1
			set plugin_url (__fundle_get_url $name)
		case 2
			set plugin_url $argv[2]
	end

	if not contains $name $__fundle_plugin_names
		set -g __fundle_plugin_names $__fundle_plugin_names $name
		set -g __fundle_plugin_urls $__fundle_plugin_urls $plugin_url
	end
end

function __fundle_version -d "prints fundle version"
	echo $__fundle_current_version
end

function __fundle_print_help -d "prints fundle help"
	echo "usage: fundle (init | plugin | plugins | install | self-update | version | help)"
end

function __fundle_plugins -d "list registered plugins"
	if begin; contains -- -s $argv; or contains -- --short $argv; end
		for name in $__fundle_plugin_names
			echo $name
		end
	else
		for i in (__fundle_seq (count $__fundle_plugin_names))
			echo {$__fundle_plugin_names[$i]}\n\t{$__fundle_plugin_urls[$i]}
		end
	end
end

function fundle -d "run fundle"
	if __fundle_no_git
		return 1
	end

	set -l sub_args ""

	switch (count $argv)
		case 0
			__fundle_print_help
			return 1
		case 1
		case '*'
			set sub_args $argv[2..-1]
	end

	switch $argv[1]
		case "init"
			__fundle_init $sub_args
		case "plugin"
			__fundle_plugin $sub_args
		case "plugins"
			__fundle_plugins $sub_args
		case "install"
			__fundle_install $sub_args
		case "self-update"
			__fundle_self_update
		case "version" -v --version
			__fundle_version
		case "help" -h --help
			__fundle_print_help
			return 0
		case "*"
			__fundle_print_help
			return 1
	end
end
