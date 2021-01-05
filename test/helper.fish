if test -z "$current_dirname"
	set current_dirname (cd (dirname (status -f)); and pwd)
end
source $current_dirname/../functions/fundle.fish

function __fundle_common_setup
	__fundle_cleanup_plugins
	__fundle_set_tmpdir
	mkdir -p $current_dirname/fundle
end

function __fundle_set_tmpdir
	set -g fundle_plugins_dir $current_dirname/fundle
end

function __fundle_cleanup_plugins
	set -e __fundle_plugin_names
	set -e __fundle_plugin_urls
	set -e __fundle_plugin_name_paths
	set -e __fundle_loaded_plugins
	return 0
end

function __fundle_clean_tmp_dir
	rm -rf $current_dirname/fundle
end

function __fundle_gitify -a git_dir
	cd $git_dir
	git init -b main > /dev/null
	git config user.name 'Daniel Perez' > /dev/null
	git config user.email 'tuvistavie@gmail.com' > /dev/null
	git config commit.gpgsign 'false' > /dev/null
	git add . > /dev/null
	git commit -m "Initial commit" > /dev/null
	cd $current_dirname/fundle
end

function __fundle_clean_gitify -a git_dir
	rm -rf $git_dir/.git
end
