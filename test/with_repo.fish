source $current_dirname/helper.fish

function setup
	__fundle_common_setup
	set -g plugin 'foo/with_init'
	set -g repo $current_dirname/fixtures/$plugin
	__fundle_gitify $repo
end

function teardown
	__fundle_clean_gitify $repo
	__fundle_clean_tmp_dir
end
