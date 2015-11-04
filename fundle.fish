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

function __fundle_get_url -d "returns the url for the given plugin"
	echo "https://github.com/"$argv[1]".git"
end

function __fundle_update_plugin -d "update the given plugin"
	cd $argv[1]
	git remote set-url origin $argv[2]
	git pull --rebase origin master
	cd -
end

function __fundle_download_plugin -d "download the given plugin"
	if __fundle_no_git
		return 1
	end

	set -l plugin_dir (__fundle_plugins_dir)/$argv[1]
	set -l git_url $argv[2]
	set -l upgrade ""

	if begin; contains -- -u $argv; or contains -- --upgrade $argv; end
		set upgrade true
	end

	if test -d $plugin_dir
		if test -n "$upgrade"
			__fundle_update_plugin $plugin_dir $git_url
		else
			echo "$argv[1] installed in $plugin_dir"
		end
	else
		git clone $git_url $plugin_dir
	end
end

function __fundle_show_doc_msg -d "show a link to fundle docs"
	if test (count $argv) -ge 1
		echo $argv
	end
	echo "See the docs for more info. https://github.com/tuvistavie/fundle"
end

function __fundle_check_dir -d "check if fundle dir exists and warn if not"
	set -l fundle_dir (__fundle_plugins_dir)
	if not test -d $fundle_dir
		__fundle_show_doc_msg "$fundle_dir is not a directory. You probably need to run 'fundle install'."
	end
end

function __fundle_plugin_path -d "get the path in the given plugin"
	set -l suffix ""
	if test (count $argv) -eq 2
		set suffix "/$argv[2]"
	end
	echo (__fundle_plugins_dir)/$argv[1]$suffix
end

function __fundle_init -d "initialize fundle"
	set -l fundle_dir (__fundle_plugins_dir)

	if test (count $__fundle_plugin_names) -eq 0
		__fundle_show_doc_msg "No plugin registered. You need to call 'fundle plugin NAME' before using 'fundle init'"
		return 1
	end

	for plugin in $__fundle_plugin_names
		if not test -d (__fundle_plugin_path $plugin)
			__fundle_show_doc_msg "$plugin not installed. You may need to run 'fundle install'"
			continue
		end

		set -l init_file (__fundle_plugin_path $plugin "init.fish")
		set -l functions_dir (__fundle_plugin_path $plugin "functions")
		set -l completions_dir (__fundle_plugin_path $plugin "completions")

		if begin; test -d $functions_dir; and not contains $functions_dir $fish_function_path; end
			set fish_function_path $functions_dir $fish_function_path
		end

		if begin; test -d $completions_dir; and not contains $completions_dir $fish_complete_path; end
			set fish_complete_path $dir $fish_complete_path
		end

		if test -f $init_file
			source $init_file
			# if init.fish found, do not read other files
			continue
		end

		# read all *.fish files if no init.fish found
		for f in (find (__fundle_plugin_path $plugin) -maxdepth 1 -iname "*.fish")
			source $f
		end
	end
end

function __fundle_install -d "install plugin"
	if test (count $__fundle_plugin_names) -eq 0
		__fundle_show_doc_msg "No plugin registered. You need to call 'fundle plugin NAME' before using 'fundle install'"
	end

	for i in (seq (count $__fundle_plugin_names))
		__fundle_download_plugin $__fundle_plugin_names[$i] $__fundle_plugin_urls[$i] $argv
	end
	__fundle_init
end

function __fundle_plugin -d "add plugin to fundle"
	set -l plugin_url ""
	switch (count $argv)
		case 0
			echo "plugin needs at least one parameter."
			return 1
		case 1
			set plugin_url (__fundle_get_url $argv[1])
		case 2
			set plugin_url $argv[2]
	end

	if not contains $argv[1] $__fundle_plugin_names
		set -g __fundle_plugin_names $__fundle_plugin_names $argv[1]
		set -g __fundle_plugin_urls $__fundle_plugin_urls $plugin_url
	end
end

function __fundle_print_help -d "prints fundle help"
	echo "usage: fundle (init | plugin | install | help)"
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
		case "install"
			__fundle_install $sub_args
		case "help" -h --help
			__fundle_print_help
			return 0
	end
end
