source $DIRNAME/../functions/fundle.fish

function -S __fundle_common_setup
	__fundle_cleanup_plugins
	__fundle_set_tmpdir
	mkdir -p $DIRNAME/fundle
end

function -S __fundle_set_tmpdir
	set -g fundle_plugins_dir $DIRNAME/fundle
end

function -S __fundle_cleanup_plugins
	set -e __fundle_plugin_names
	set -e __fundle_plugin_urls
	set -e __fundle_plugin_paths
	set -e __fundle_loaded_plugins
	return 0
end

function -S __fundle_clean_tmp_dir
	rm -rf $DIRNAME/fundle
end

function -S __fundle_gitify -a git_dir
	cd $git_dir
	git init > /dev/null
	git config user.name 'Daniel Perez' > /dev/null
	git config user.email 'tuvistavie@gmail.com' > /dev/null
	git add . > /dev/null
	git commit -m "Initial commit" > /dev/null
	cd $DIRNAME
end

function -S __fundle_clean_gitify -a git_dir
	rm -rf $git_dir/.git
end
