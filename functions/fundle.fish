function __fundle_seq -a upto
	seq 1 1 $upto ^ /dev/null
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

function __fundle_init -d "initialize fundle"
	set -l fundle_dir (__fundle_plugins_dir)

	if test (count $__fundle_plugin_names) -eq 0
		__fundle_show_doc_msg "No plugin registered. You need to call 'fundle plugin NAME' before using 'fundle init'"
		return 1
	end

	for plugin in $__fundle_plugin_names
		set -l plugin_dir "$fundle_dir/$plugin"

		if not test -d $plugin_dir
			__fundle_show_doc_msg "$plugin not installed. You may need to run 'fundle install'"
			continue
		end

		set -l init_file "$plugin_dir/init.fish"
		set -l functions_dir "$plugin_dir/functions"
		set -l completions_dir  "$plugin_dir/completions"

		if begin; test -d $functions_dir; and not contains $functions_dir $fish_function_path; end
			set fish_function_path $functions_dir $fish_function_path
		end

		if begin; test -d $completions_dir; and not contains $completions_dir $fish_complete_path; end
			set fish_complete_path $completions_dir $fish_complete_path
		end

		if test -f $init_file
			source $init_file
			# if init.fish found, do not read other files
			continue
		end

		# read all *.fish files if no init.fish found
		for f in (find $plugin_dir -maxdepth 1 -iname "*.fish")
			source $f
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

function __fundle_print_help -d "prints fundle help"
	echo "usage: fundle (init | plugin | plugins | install | help)"
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
		case "help" -h --help
			__fundle_print_help
			return 0
		case "*"
			__fundle_print_help
			return 1
	end
end
