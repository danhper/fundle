source $DIRNAME/helper.fish

function -S setup
	__fundle_set_tmpdir
	set plugin 'foo/with_init'
	set repo $DIRNAME/fixtures/$plugin
	__fundle_gitify $repo
end

function -S teardown
	__fundle_clean_gitify $repo
	__fundle_clean_tmp_dir
end
